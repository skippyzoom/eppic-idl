;+
; Create a data dictionary for a plane of EPPIC data
;
; This function will extract the 2-D data plane specified
; by axes at each time step of fdata if fdata is (3+1)-D. 
; It will also optionally rotate the extracted 2-D planes.
; This function will always return a logically (2+1)-D
; array, even if fdata has one time step.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FDATA (required)
;    A (2+1)-D or (3+1)-D array of data from an EPPIC run.
; RANGES (default: [0,nx,0,ny,0,nz])
;    A four- or six-element array or dictionary specifying the
;    physical x, y, and z ranges to return. The elements are 
;    (x0,xf,y0,yf,z0,zf), where [x0,xf) is the range of x 
;    values, and similarly for y and z.
; ZERO_POINT (default: 0)
;    The point at which to subscript the axis perpendicular
;    to the requested plane.
; AXES (default: 'xy')
;    Simulation axes to extract from HDF data. If the
;    simulation is 2 D, read_ph5_plane.pro will ignore
;    this parameter.
; ROTATE (default: 0)
;    Integer indcating whether, and in which direction,
;    to rotate the data array and axes before creating a
;    movie. This parameter corresponds to the 'direction'
;    parameter in IDL's rotate.pro.
; PATH (default: './')
;    The fully qualified path from which to build an EPPIC
;    parameter dictionary, if necessary.
; PARAMS (default: none)
;    The parameter dictionary from an EPPIC run. If the user 
;    does not supply params, this function will read it from 
;    path.
; <return>
;    A (2+1)-D array extracted from fdata.
;-
function set_image_plane, fdata, $
                          ranges=ranges, $
                          zero_point=zero_point, $
                          axes=axes, $
                          rotate=rotate, $
                          path=path, $
                          params=params

  ;;==Defaults and guards
  if n_elements(zero_point) eq 0 then zero_point = 0
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(rotate) eq 0 then rotate = 0
  if n_elements(path) eq 0 then path = './'
  if n_elements(params) eq 0 then params = set_eppic_params(path=path)
  if n_elements(ranges) eq 0 then $
     ranges = [0,params.nx*params.nsubdomains/params.nout_avg, $
               0,params.ny/params.nout_avg, $
               0,params.nz/params.nout_avg]
  if params.ndim_space eq 2 then axes = 'xy'

  ;;==Check input ranges
  ranges_in = ranges
  ranges = set_ranges(ranges,params=params,path=path)

  ;;==Extract x, y, and z ranges
  x0 = ranges.x0
  xf = ranges.xf
  y0 = ranges.y0
  yf = ranges.yf
  z0 = ranges.z0
  zf = ranges.zf

  ;;==Restore input
  ranges = ranges_in

  ;;==Get dimensions of data array
  fsize = size(fdata)
  ndim = fsize[0]
  if ndim eq 2 then nt = 1 $
  else nt = fsize[ndim]
  nx = fsize[1]
  ny = fsize[2]
  if ndim eq 4 then nz = fsize[3] $
  else nz = 1
  if ndim ne 4 then fdata = reform(fdata,nx,ny,nz,nt)

  ;;==Declare the output dictionary
  plane = dictionary()

  ;;==Set plane-specific variables
  case 1B of
     strcmp(axes,'xy'): begin
        plane['dx'] = params.dx*params.nout_avg
        plane['dy'] = params.dy*params.nout_avg
        plane['x'] = plane.dx*(x0 + indgen(nx))
        plane['y'] = plane.dy*(y0 + indgen(ny))
        ;; if ndim eq 4 then fdata = reform(fdata[*,*,zero_point,*])
        fdata = reform(fdata[*,*,zero_point,*],nx,ny,nt)
     end
     strcmp(axes,'xz'): begin
        plane['dx'] = params.dx*params.nout_avg
        plane['dy'] = params.dz*params.nout_avg
        plane['x'] = plane.dx*(x0 + indgen(nx))
        plane['y'] = plane.dz*(z0 + indgen(nz))
        ;; if ndim eq 4 then fdata = reform(fdata[*,zero_point,*,*])
        fdata = reform(fdata[*,*,zero_point,*],nx,nz,nt)
     end
     strcmp(axes,'yz'): begin
        plane['dx'] = params.dy*params.nout_avg
        plane['dy'] = params.dz*params.nout_avg
        plane['x'] = plane.dy*(y0 + indgen(ny))
        plane['y'] = plane.dz*(z0 + indgen(nz))
        ;; if ndim eq 4 then fdata = reform(fdata[zero_point,*,*,*])
        fdata = reform(fdata[*,*,zero_point,*],ny,nz,nt)
     end
  endcase

  ;;==Rotate data, if requested
  if rotate gt 0 then begin
     if rotate mod 2 then begin
        tmp = plane.y
        plane.y = plane.x
        plane.x = tmp
        psize = size(fdata)
        tmp = fdata
        fdata = make_array(psize[2],psize[1],nt,type=psize[4],/nozero)
        for it=0,nt-1 do fdata[*,*,it] = rotate(tmp[*,*,it],rotate)
     endif $
     else for it=0,nt-1 do fdata[*,*,it] = rotate(fdata[*,*,it],rotate)
  endif

  plane['f'] = fdata
  return, plane
end
