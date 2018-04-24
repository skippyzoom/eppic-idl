;+
; Read EPPIC data and return a (2+1)-D array
;
; This function builds an array of data from files 
; written in the parallel HDF5 format. This function
; returns an array with dimensions (nx,ny,nt). 
; For spatially  2-D data, it returns the full data set; 
; for 3-D data, it returns a logically 3-D data set 
; comprising data in the requested plane as a function of 
; time.
;
; Created by Matt Young.
; The FT portion of this code is based on code written by
; Meers Oppenheim and Liane Tarnecki.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA_NAME
;    The name of the data quantity to read. If the data
;    does not exist, read_ph5_plane.pro will return 0
;    and this routine will exit gracefully.
; TIMESTEP (default: all available files)
;    Simulation time steps at which to read data. Even though this
;    function doesn't set an explicit default, its default
;    behavior (via file_search) is to read all available time steps.
; EXT (default: 'h5')
;    File extension of data to read.
; AXES (default: 'xy')
;    Simulation axes to extract from HDF data. If the
;    simulation is 2 D, read_ph5_plane.pro will ignore
;    this parameter.
; ZERO_POINT (default: 0)
;    The point at which to subscript the axis perpendicular
;    to the requested plane.
; RANGES (default: [0,nx,0,ny])
;    A four-element array specifying logical x and y ranges
;    to return. The elements are [x0,xf,y0,yf], where 
;    x0 and xf are the bounds of the first dimension specified
;    by 'axes' and y0 and yf are the bounds of the second
;    dimension.
; NORMAL (default: unset)
;    If set, indicates that ranges are normalized to simulation dimensions.
; DATA_TYPE (default: 4)
;    IDL numerical data type of simulation output, typically either 4
;    (float) for spatial data or 6 (complex) for Fourier-transformed
;    data.
; DATA_ISFT (default: 0)
;    Boolean that represents whether the EPPIC data quantity is
;    Fourier-transformed or not.
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
function read_ph5_plane, data_name, $
                         timestep=timestep, $
                         ext=ext, $
                         axes=axes, $
                         zero_point=zero_point, $
                         ranges=ranges, $
                         normal=normal, $
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
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(zero_point) eq 0 then zero_point = 0
  data_path = terminal_slash(data_path)
  if n_elements(info_path) eq 0 then $
     info_path = strmid(data_path,0, $
                        strpos(data_path,'parallel',/reverse_search))
  if n_elements(lun) eq 0 then lun = -1

  ;;==Read in run parameters
  params = set_eppic_params(path=info_path)

  ;;==Extract global dimensions from parameters
  nout_avg = params.nout_avg
  ndim_space = params.ndim_space

  ;;==Default ranges (requires simulation dimensions)
  if n_elements(ranges) eq 0 then begin
     case 1B of
        strcmp(axes,'xy') || strcmp(axes,'yx'): $
           ranges = [0,params.nx*params.nsubdomains,0,params.ny]
        strcmp(axes,'xz') || strcmp(axes,'zx'): $
           ranges = [0,params.nx*params.nsubdomains,0,params.nz]
        strcmp(axes,'yz') || strcmp(axes,'zy'): $
           ranges = [0,params.ny,0,params.nz]
     endcase
     if ~keyword_set(data_isft) then ranges /= params.nout_avg
  endif
  if ranges[1] lt ranges[0] then $
     message, "Must have ranges[0] ("+string(ranges[1])+ $
              ") < ranges[1] ("+string(ranges[0])+")"
  if ranges[3] lt ranges[2] then $
     message, "Must have ranges[2] ("+string(ranges[2])+ $
              ") < ranges[3] ("+string(ranges[3])+")"

  ;;==Fix axes for 2-D runs
  if ndim_space eq 2 then axes = 'xy'

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
     ndim_full = (size(tmp))[1]
  endif $
  else begin
     tmp = get_h5_data(h5_file_ref,data_name)
     ndim_full = (size(tmp))[0]
  endelse

  if n_elements(tmp) ne 0 && ndim_full eq ndim_space then begin
     n_dim = 2
     plane = build_reference_plane(axes, $
                                   ranges = ranges, $
                                   params = params, $
                                   normal = normal)

     if keyword_set(data_isft) then begin
        ft_template = {ikx:0, iky:0, val:complex(0)}
     endif $
     else begin
        plane.nx /= nout_avg
        plane.ny /= nout_avg
     endelse
     x0 = fix(plane.x0)
     xf = fix(plane.xf)
     y0 = fix(plane.y0)
     yf = fix(plane.yf)
     nxp = xf-x0
     nyp = yf-y0
     data = make_array(nxp,nyp,nt,type=data_type)
     tmp = !NULL

  endif else n_dim = 0

  if nt eq 1 then data = reform(data,[size(data,/dim),1])

  ;; if n_dim eq 2 || n_dim eq 3 then begin
  if n_dim eq 2 then begin

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
              ft_struct.iky = reform(tmp_ind[plane.ind_x,*])
              ft_struct.ikx = reform(tmp_ind[plane.ind_y,*])              
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
              ft_array[ft_struct.ikx,ft_struct.iky] = $
                 ft_struct.val
              ft_size = size(ft_array)
              if ft_size[0] eq 1 then $
                 ft_array = reform(ft_array,ft_size[1],1)
              ft_size = size(ft_array)
              ft_struct = !NULL
              full_array = complexarr(plane.nx,plane.ny)
              full_array[0:ft_size[2]-1,0:ft_size[1]-1] = $
                 transpose(ft_array,[1,0])
              ft_array = !NULL              
              full_array = shift(full_array,[1,1])
              full_array = conj(full_array)
              data[*,*,it] = full_array[x0:xf-1,y0:yf-1]
           endif else null_count++ ;tmp_data exists?
        endfor                     ;time step loop
     endif $                       ;FT data
     else begin
        for it=0,nt-1 do begin
           ;;==Read data set
           tmp = get_h5_data(h5_file[it],data_name, $
                             lun = lun, $
                             start = plane.h5_start, $
                             count = plane.h5_count)
           ;;==Assign to return array
           if n_elements(tmp) ne 0 then begin
              data[*,*,it] = (transpose(tmp,[1,0]))[x0:xf-1,y0:yf-1]
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
     plane = !NULL
     return, data

  endif $                       ;n_dims eq 2 or 3
  else if n_dim eq 0 then $
     printf, lun,"[READ_PH5_PLANE] Could not read ",data_name $
  else begin
     printf, lun,"[READ_PH5_PLANE] Only works for input data"
     printf, lun,"                 with 2 or 3 spatial dimensions."
  endelse
end
