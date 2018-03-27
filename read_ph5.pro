;+
; Read EPPIC parallel HDF data and return a time-stepped array
;
; Created by Matt Young.
; The FT portion of this code is based on code written by
; Meers Oppenheim and Liane Tarnecki.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA_NAME
;    The name of the data quantity to read. If the data
;    does not exist, read_ph5.pro this function will exit 
;    gracefully.
; EXT (default: 'h5')
;    File extension of data to read.
; TIMESTEP (default: 0)
;    Simulation time steps at which to read data.
; RANGES (default: [0,nx,0,ny,0,nz])
;    A four- or six-element array or dictionary specifying the
;    x, y, and z ranges to return. The elements are 
;    (x0,xf,y0,yf,z0,zf), where [x0,xf) is the range of x 
;    values, and similarly for y and z.
; DATA_TYPE (default: 4)
;    IDL numerical data type of simulation output, 
;    typically either 4 (float) for spatial data
;    or 6 (complex) for Fourier-transformed data.
; DATA_ISFT (default: 0)
;    Boolean that represents whether the EPPIC data 
;    quantity is Fourier-transformed or not.
; INFO_PATH (default: './')
;    Fully qualified path to the simulation parameter
;    file (ppic3d.i or eppic.i).
; DATA_PATH (default: './')
;    Fully qualified path to the simulation data.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; VERBOSE (default: unset)
;    Print runtime information.
; <return>
;    A logically (2+1)-D array of the type specified by data_type.
;-
function read_ph5, data_name, $
                   ext=ext, $
                   timestep=timestep, $
                   ranges=ranges, $
                   data_type=data_type, $
                   data_isft=data_isft, $
                   info_path=info_path, $
                   data_path=data_path, $
                   lun=lun, $
                   verbose=verbose

  ;;==Defaults and guards
  if n_elements(ext) eq 0 then ext = 'h5'
  if n_elements(data_type) eq 0 then data_type = 4
  if n_elements(data_path) eq 0 then data_path = './'
  data_path = terminal_slash(data_path)
  if n_elements(info_path) eq 0 then $
     info_path = strmid(data_path,0, $
                        strpos(data_path,'parallel',/reverse_search))
  if n_elements(lun) eq 0 then lun = -1

  ;;==Read in run parameters
  params = set_eppic_params(path=info_path)

  ;;==Extract dimensional quantities from parameters
  nx = params.nx*params.nsubdomains
  ny = params.ny
  nz = params.nz
  nout_avg = params.nout_avg
  ndim_space = params.ndim_space

  ;;==Check ranges
  ranges = set_ranges(ranges,params=params,path=path)

  ;;==Trim the dot from file extension pattern
  if strcmp(strmid(ext,0,1),'.') then $
     ext = strmid(ext,1,strlen(ext))

  ;;==Search for available files...
  h5_file = file_search(data_path+'*.'+ext,count=n_files)
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
  h5_file_ref = expand_path(data_path+path_sep()+'parallel000000.h5')
  
  ;;==Select a subset of time steps, if requested
  if n_elements(timestep) ne 0 then h5_file = h5_file[timestep/nout]

  ;;==Get the size of the subset
  nt = n_elements(h5_file)

  ;;==Set up data array
  if keyword_set(data_isft) then begin
     tmp = get_h5_data(h5_file_ref,data_name+'_index')
     dims_eq = (ndim_space eq (size(tmp))[1])
  endif $
  else begin
     tmp = get_h5_data(h5_file_ref,data_name)
     dims_eq = (ndim_space eq (size(tmp))[0])
  endelse
  tmp = !NULL
  if keyword_set(data_isft) then begin
     if ndim_space eq 2 then $
        ft_template = {ikx:0, iky:0, val:complex(0)} $
     else $
        ft_template = {ikx:0, iky:0, ikz:0, val:complex(0)}
  endif
  if dims_eq then begin
     n_dim = ndim_space 
     x0 = ranges.x0
     xf = ranges.xf
     y0 = ranges.y0
     yf = ranges.yf
     z0 = ranges.z0
     zf = ranges.zf
     nxp = xf-x0
     nyp = yf-y0
     nzp = zf-z0
     data = reform(make_array(nxp,nyp,nzp,nt,type=data_type))
  endif $
  else n_dim = 0

  ;;==Retain singular time dimension
  if nt eq 1 then data = reform(data,[size(data,/dim),1])
  ndim_data = size(data,/n_dim)-1

  ;;==If data is 2- or 3-D, proceed
  if n_dim eq 2 || n_dim eq 3 then begin

     ;;==Loop over all available time steps
     if keyword_set(verbose) then $
        printf, lun,"[READ_PH5] Reading ",data_name,"..."

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
                 end
                 3: begin
                    full_array = complexarr(full_size[1], $
                                            full_size[2],full_size[3])
                    full_array[0:ft_size[1]-1, $
                               0:ft_size[2]-1,0:ft_size[3]-1] = ft_array
                    ft_array = !NULL                 
                    full_array = shift(full_array,[1,1,0])
                    full_array = conj(full_array)
                 end
              endcase           ;simulated data dimensions
              if ndim_data eq 2 then begin
                 data[*,*,it] = reform(full_array[x0:xf-1, $
                                                  y0:yf-1, $
                                                  z0:zf-1])
              endif $
              else begin
                 data[*,*,*,it] = full_array[x0:xf-1, $
                                             y0:yf-1, $
                                             z0:zf-1]
              endelse
           endif else null_count++ ;tmp_data exists?
        endfor                     ;time step loop
     endif $                       ;FT data
     else begin
        for it=0,nt-1 do begin
           ;;==Read data set
           tmp = get_h5_data(h5_file[it],data_name)
           ;;==Assign to return array
           if n_elements(tmp) ne 0 then begin
              if ndim_space eq 2 then tmp = transpose(tmp,[1,0]) $
              else tmp = transpose(tmp,[2,1,0])
              if ndim_data eq 2 then begin
                 data[*,*,it] = reform(tmp[x0:xf-1, $
                                           y0:yf-1, $
                                           z0:zf-1])
              endif $
              else begin
                 data[*,*,*,it] = tmp[x0:xf-1, $
                                      y0:yf-1, $
                                      z0:zf-1]
              endelse

           endif else null_count++ ;tmp_data exists?
           tmp = !NULL             ;time step loop
        endfor
     endelse

     ;;==Let user know about missing data (not necessarily an error)
     if keyword_set(verbose) && null_count gt 0 then $
        printf, lun,"[READ_PH5] Warning: Did not find '", $
                data_name+"' in ", $
                strcompress(null_count,/remove_all),"/", $
                strcompress(nt,/remove_all)," files."

     if n_elements(data) eq 0 then data = !NULL
     return, data

  endif $                       ;n_dims eq 2 or 3
  else if n_dim eq 0 then $
     printf, lun,"[READ_PH5] Could not read ",data_name $
  else begin
     printf, lun,"[READ_PH5] Only works for input data"
     printf, lun,"           with 2 or 3 spatial dimensions."
  endelse
end
