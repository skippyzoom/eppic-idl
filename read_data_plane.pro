;+
; Return a (2+1)-D context of an EPPIC data quantity
;
; This routine reads time-dependent data of a single 2-D
; plane from 2-D or 3-D HDF files produced by EPPIC and 
; returns a plane context containing a (2+1)-D array, as
; well as other parameters necessary for graphics.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA_NAME
;    The name of the data quantity to read. If the data
;    does not exist, read_ph5.pro will return 0 and this 
;    routine will exit gracefully.
; AXES (default: 'xy')
;    Simulation axes to extract from HDF data. If the
;    simulation is 2 D, read_ph5.pro will ignore this 
;    parameter.
; RANGES (default: [0,1,0,1,0,1]
;    A four- or six-element array of normalized ranges.
;    This function will convert ranges into physical
;    units for use in lower functions.
; DATA_TYPE (default: 4)
;    IDL numerical data type of simulation output, 
;    typically either 4 (float) for spatial data
;    or 6 (complex) for Fourier-transformed data.
; DATA_ISFT (default: 0)
;    Boolean that represents whether the EPPIC data 
;    quantity is Fourier-transformed or not.
; ROTATE (default: 0)
;    Integer indcating whether, and in which direction,
;    to rotate the data array and axes before creating a
;    movie. This parameter corresponds to the 'direction'
;    parameter in IDL's rotate.pro.
; INFO_PATH (default: './')
;    Fully qualified path to the simulation parameter
;    file (ppic3d.i or eppic.i).
; DATA_PATH (default: './')
;    Fully qualified path to the simulation data.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
;-
function read_data_plane, data_name, $
                          timestep=timestep, $
                          axes=axes, $
                          ranges=ranges, $
                          data_type=data_type, $
                          data_isft=data_isft, $
                          rotate=rotate, $
                          info_path=info_path, $
                          data_path=data_path, $
                          lun=lun

  ;;==Defaults and guards
  if n_elements(timestep) eq 0 then timestep = 0
  nts = n_elements(timestep)
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(ranges) eq 0 then ranges = [0,1,0,1,0,1]
  if n_elements(ranges) eq 4 then ranges = [ranges,0,1]
  if n_elements(data_type) eq 0 then data_type = 4
  if n_elements(data_isft) eq 0 then data_isft = 0B
  if n_elements(rotate) eq 0 then rotate = 0
  if n_elements(info_path) eq 0 then info_path = './'
  if n_elements(data_path) eq 0 then data_path = './'
  if n_elements(lun) eq 0 then lun = -1

  ;;==Read simulation parameters
  params = set_eppic_params(path=info_path)

  ;;==Convert ranges to physical indices
  norm_ranges = ranges
  if keyword_set(data_isft) then begin
     x0 = fix(params.nx*params.nsubdomains*norm_ranges[0])
     xf = fix(params.nx*params.nsubdomains*norm_ranges[1])
     y0 = fix(params.ny*norm_ranges[2])
     yf = fix(params.ny*norm_ranges[3])
     z0 = fix(params.nz*norm_ranges[4])
     zf = fix(params.nz*norm_ranges[5])
  endif $
  else begin
     x0 = fix(params.nx*params.nsubdomains*norm_ranges[0])/params.nout_avg
     xf = fix(params.nx*params.nsubdomains*norm_ranges[1])/params.nout_avg
     y0 = fix(params.ny*norm_ranges[2])/params.nout_avg
     yf = fix(params.ny*norm_ranges[3])/params.nout_avg
     z0 = fix(params.nz*norm_ranges[4])/params.nout_avg
     zf = fix(params.nz*norm_ranges[5])/params.nout_avg
  endelse
  phys_ranges = dictionary('x0',x0, 'xf',xf, $
                           'y0',y0, 'yf',yf, $
                           'z0',z0, 'zf',zf)

  ;;==Read data at each time step
  if strcmp(data_name,'e',1,/fold_case) then $
     read_name = 'phi' $
  else $
     read_name = data_name
  rdata = read_ph5(read_name, $
                   ext = '.h5', $
                   timestep = timestep, $
                   data_type = data_type, $
                   data_isft = data_isft, $
                   data_path = data_path, $
                   info_path = info_path, $
                   ranges = phys_ranges, $
                   /verbose)

  ;;==Check dimensions
  rsize = size(rdata)
  if rsize[0] eq 3 then begin

     ;;==Set the (2+1)-D array for imaging
     plane = set_image_plane(rdata, $
                             ranges = phys_ranges, $
                             axes = axes, $
                             rotate = rotate, $
                             params = params, $
                             path = path)
     return, plane

  endif $
  else begin
     printf, lun,"[READ_DATA_PLANE] Could not build plane for:"
     printf, lun,"                  data_name = "+data_name
     printf, lun,"                  axes = "+axes
  endelse
end
