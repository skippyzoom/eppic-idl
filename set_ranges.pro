;+
; Return a six-element dictionary of physical ranges 
; appropriate for subscripting EPPIC data arrays.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; RANGES (required)
;    A four- or six-element array or dictionary of physical
;    ranges. Elements must be ordered [x0,xf,y0,yf,z0,zf],
;    where x0 ge 0 is the lower x-axis bound, xf lt nx*nsubdomains
;    is the upper x-axis bound, and so on for y and z.
; PATH (default: './')
;    The fully qualified path from which to build an EPPIC
;    parameter dictionary, if necessary.
; PARAMS (default: none)
;    The parameter dictionary from an EPPIC run. If the user 
;    does not supply params, this function will read it from 
;    path.
; <return>
;    A dictionary with integer elements x0,xf,y0,yf,z0,zf.
;-
function set_ranges, ranges, $
                     path=path, $
                     params=params

  ;;==Defaults and guards
  if n_elements(path) eq 0 then path = './'
  if n_elements(params) eq 0 then params = set_eppic_params(path=path)

  ;;==Extract dimensional quantities from parameters
  nx = params.nx*params.nsubdomains
  ny = params.ny
  nz = params.nz
  nout_avg = params.nout_avg
  ndim_space = params.ndim_space

  ;;==Check ranges
  ;; if n_elements(ranges) eq 0 then $
  ;;    ranges = dictionary('x0',0,'xf',nx,'y0',0,'yf',ny,'z0',0,'zf',nz)
  if n_elements(ranges) eq 0 then ranges = [0,nx,0,ny,0,nz]
  if isa(ranges,/float,/array) then ranges = long(ranges)
  if isa(ranges,/int,/array) then begin
     if n_elements(ranges) eq 4 then $
        ranges = [ranges,0,nz]
     ranges = dictionary('x0',ranges[0],'xf',ranges[1], $
                         'y0',ranges[2],'yf',ranges[3], $
                         'z0',ranges[4],'zf',ranges[5])
  endif $
  else if isa(ranges,'dictionary') then begin
     if n_elements(ranges) eq 4 then begin
        ranges['z0'] = 0
        ranges['zf'] = nz
     endif
  endif
  if ndim_space eq 2 then ranges.zf = ranges.z0 + 1
  if ranges.xf lt ranges.x0 then $
     message, "Must have ranges.x0 ("+string(ranges.xf)+ $
              ") =< ranges.xf ("+string(ranges.x0)+")"
  if ranges.yf lt ranges.y0 then $
     message, "Must have ranges.y0 ("+string(ranges.y0)+ $
              ") =< ranges.yf ("+string(ranges.yf)+")"
  if ranges.zf lt ranges.z0 then $
     message, "Must have ranges.z0 ("+string(ranges.z0)+ $
              ") =< ranges.zf ("+string(ranges.zf)+")"
  
  return, ranges
end
