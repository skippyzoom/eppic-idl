;+
; This function builds an array of data from files 
; written in the parallel HDF5 format. It is tuned
; to work with EPPIC simulation output and is based
; on read_ph5_data.pro
;
; The purpose of using this function in place of
; read_ph5_data.pro is to save memory in cases of
; large data sets. It will return an array with 
; dimensions (nx,ny,nt): for spatially  2-D data, 
; it returns the full data set; for 3-D data, it 
; returns a logically 3-D data set comprising data 
; in the requested plane as a function of time.
;-
function read_ph5_plane, data_name, $
                         ext=ext, $
                         timestep=timestep, $
                         plane=plane, $
                         center=center, $
                         type=type, $
                         data_isft=data_isft, $
                         run_dir=run_dir, $
                         path=path, $
                         lun=lun, $
                         verbose=verbose

  ;;==Defaults and guards
  if n_elements(ext) eq 0 then ext = 'h5'
  if n_elements(type) eq 0 then type = 4
  if n_elements(path) eq 0 then path = './'
  if n_elements(plane) eq 0 then plane = 'xy'
  if n_elements(center) eq 0 then center = [0,0,0]
  path = terminal_slash(path)
  if n_elements(run_dir) eq 0 then $
     run_dir = strmid(path,0,strpos(path,'parallel',/reverse_search))
  if n_elements(lun) eq 0 then lun = -1

  ;;==Read in run parameters
  params = set_eppic_params(path=run_dir)

  ;;==Extract global dimensions from parameters
  nx = params.nx*params.nsubdomains
  ny = params.ny
  nz = params.nz
  nout_avg = params.nout_avg
  ndim_space = params.ndim_space

  ;;==Trim the dot from file extension pattern
  if strcmp(strmid(ext,0,1),'.') then $
     ext = strmid(ext,1,strlen(ext))

  ;;==Search for available files...
  h5_file = file_search(path+'*.'+ext,count=n_files)
  if n_files ne 0 then begin
     ;;...If files exist, derive nout for subsetting (below)
     h5_base = file_basename(h5_file)
     all_timesteps = get_ph5timestep(h5_base)
     nout = all_timesteps[n_files-1]/n_files + 1
  endif $
  else begin
     ;;...Otherwise, throw an error
     errmsg = "Found no files with extension "+ext
     message, errmsg
  endelse

  ;;==Declare the reference file
  h5_file_ref = expand_path(path+path_sep()+'parallel000000.h5')
  
  ;;==Select a subset of time steps, if requested
  if n_elements(timestep) ne 0 then h5_file = h5_file[timestep/nout]

  ;;==Get the size of the subset
  nt = n_elements(h5_file)

  ;;==Set up array for EPPIC Fourier-transformed data
  if keyword_set(data_isft) then begin
     tmp = get_h5_data(h5_file_ref,data_name+'_index')
     if n_elements(tmp) ne 0 then begin
        n_dim = (size(tmp))[1]
        case n_dim of
           2: begin
              nxp = nx
              nyp = ny
              ft_template = {ikx:0, iky:0, val:complex(0.0,0.0)}
           end
           3: begin
              case 1B of
                 strcmp(plane,'xy') || strcmp(plane,'yx'): begin
                    nxp = nx
                    nyp = ny
                 end
                 strcmp(plane,'xz') || strcmp(plane,'zx'): begin
                    nxp = nx
                    nyp = nz
                 end
                 strcmp(plane,'yz') || strcmp(plane,'zy'): begin
                    nxp = ny
                    nyp = nz
                 end
              endcase
              ft_template = {ikx:0, iky:0, ikz:0, val:complex(0.0,0.0)}
           end 
        endcase
        data = make_array(nxp,nyp,nt,type=type)
        tmp = !NULL
     endif else n_dim = 0
  endif $
  ;;==Set up array for standard EPPIC data
  else begin
     tmp = get_h5_data(h5_file_ref,data_name)
     if n_elements(tmp) ne 0 then begin
        n_dim = (size(tmp))[0]
        case n_dim of
           2: begin 
              nxp = nx/nout_avg
              nyp = ny/nout_avg
           end
           3: begin
              case 1B of
                 strcmp(plane,'xy') || strcmp(plane,'yx'): begin
                    nxp = nx/nout_avg
                    nyp = ny/nout_avg
                 end
                 strcmp(plane,'xz') || strcmp(plane,'zx'): begin
                    nxp = nx/nout_avg
                    nyp = nz/nout_avg
                 end
                 strcmp(plane,'yz') || strcmp(plane,'zy'): begin
                    nxp = ny/nout_avg
                    nyp = nz/nout_avg
                 end
              endcase
           end
        endcase 
        data = make_array(nxp,nyp,nt,type=type)
        tmp = !NULL
     endif else n_dim = 0
  endelse   
  if nt eq 1 then data = reform(data,[size(data,/dim),1])

  if n_dim eq 2 || n_dim eq 3 then begin

     ;;==Loop over all available time steps
     if keyword_set(verbose) then $
        printf, lun,"[READ_PH5_PLANE] Reading ",data_name,"..."

     ;;==Set counted for missing data
     null_count = 0L

     ;;==Check if data is Fourier Transformed output
     if keyword_set(data_isft) then begin

        for it=0,nt-1 do begin
           ;;==Read data set
           tmp_data = get_h5_data(h5_file[it],data_name)
           if n_elements(tmp_data) ne 0 then begin
              tmp_size = size(tmp_data)
              tmp_len = (tmp_size[0] eq 1) ? 1 : tmp_size[2]
              tmp_cplx = complex(tmp_data[0,0:tmp_len-1], $
                                 tmp_data[1,0:tmp_len-1])
              ;;==Read index set
              tmp_ind = get_h5_data(h5_file[it],data_name+'_index')
              ;;==Assign to intermediate struct
              ft_struct = replicate(ft_template,tmp_len)
              ft_struct.val = reform(tmp_cplx)
              switch n_dim of 
                 3: ft_struct.ikz = reform(tmp_ind[2,*])
                 2: ft_struct.iky = reform(tmp_ind[1,*])
                 1: ft_struct.ikx = reform(tmp_ind[0,*])
              endswitch
              ;;==Free temporary variables
              tmp_data = !NULL
              tmp_ind = !NULL
              ;;==Convert to output array
              tmp_range = intarr(n_dim,2)
              for id=0,n_dim-1 do begin
                 tmp_range[id,0] = min(ft_struct.(id))
                 tmp_range[id,1] = max(ft_struct.(id))
              endfor
              ft_array = complexarr(tmp_range[*,1]-tmp_range[*,0]+1)
              case ndim_space of 
                 3: begin
                    ft_array[ft_struct.ikx,ft_struct.iky,ft_struct.ikz] = $
                       ft_struct.val
                    ft_size = size(ft_array)
                    if ft_size[0] eq 2 then $
                       ft_array = reform(ft_array,ft_size[1],ft_size[2],1) $
                    else if ft_size[0] eq 1 then $
                       ft_array = reform(ft_array,ft_size[1],1,1)
                 end
                 2: begin
                    ft_array[ft_struct.ikx,ft_struct.iky] = $
                       ft_struct.val
                    ft_size = size(ft_array)
                    if ft_size[0] eq 1 then $
                       ft_array = reform(ft_array,ft_size[1],1)
                 end
                 1: ft_array[ft_struct.ikx] = ft_struct.val
              endcase
              ft_size = size(ft_array)
              ft_struct = !NULL
              full_size = [ndim_space,nx,ny,nz]
              case ndim_space of
                 2: begin
                    full_array = complexarr(full_size[1], $
                                            full_size[2])
                    full_array[0:ft_size[1]-1,0:ft_size[2]-1] = ft_array
                    ft_array = !NULL              
                    full_array = shift(full_array,[1,1])
                    full_array = conj(full_array)
                    data[*,*,it] = full_array
                 end
                 3: begin
                    full_array = complexarr(full_size[1], $
                                            full_size[2],full_size[3])
                    full_array[0:ft_size[1]-1, $
                               0:ft_size[2]-1,0:ft_size[3]-1] = ft_array
                    ft_array = !NULL                 
                    full_array = shift(full_array,[1,1,0])
                    full_array = conj(full_array)
                    case 1B of 
                       strcmp(plane,'xy') || strcmp(plane,'yx'): $
                          data[*,*,it] = reform(full_array[*,*,center[2]])
                       strcmp(plane,'xz') || strcmp(plane,'zx'): $
                          data[*,*,it] = reform(full_array[*,center[1],*])
                       strcmp(plane,'yz') || strcmp(plane,'zy'): $
                          data[*,*,it] = reform(full_array[center[0],*,*])
                    endcase
                 end
              endcase              ;data dimensions
           endif else null_count++ ;tmp_data exists?
        endfor                     ;time step loop
     endif $
     else begin
        for it=0,nt-1 do begin
           ;;==Read data set
           tmp = get_h5_data(h5_file[it],data_name)
           ;;==Assign to return array
           if n_elements(tmp) ne 0 then begin
              case ndim_space of
                 2: data[*,*,it] = transpose(tmp,[1,0])
                 3: begin
                    tmp = transpose(tmp,[2,1,0])
                    case 1B of 
                       strcmp(plane,'xy') || strcmp(plane,'yx'): $
                          data[*,*,it] = reform(tmp[*,*,center[2]])
                       strcmp(plane,'xz') || strcmp(plane,'zx'): $
                          data[*,*,it] = reform(tmp[*,center[1],*])
                       strcmp(plane,'yz') || strcmp(plane,'zy'): $
                          data[*,*,it] = reform(tmp[center[0],*,*])
                    endcase                    
                 end
              endcase
           endif else null_count++ ;tmp_data exists?
           tmp = !NULL             ;time step loop
        endfor
     endelse

     ;;==Let user know about missing data (not necessarily an error)
     if keyword_set(verbose) && null_count gt 0 then $
        printf, lun,"[READ_PH5_PLANE] Warning: Did not find '", $
               data_name+"' in ", $
               strcompress(null_count,/remove_all),"/", $
               strcompress(nt,/remove_all)," files."

     if n_elements(data) eq 0 then data = !NULL
     return, data

  endif $                       ;n_dims eq 2 or 3
  else if n_dim eq 0 then $
     printf, lun,"[READ_PH5_PLANE] Could not read ",data_name $
  else begin
     printf, lun,"[READ_PH5_PLANE] Only works for input data"
     printf, lun,"                 with 2 or 3 spatial dimensions."
  endelse
end
