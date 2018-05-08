;+
; Import parameters appropriate to a logically (2+1)-D plane of EPPIC data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (default: './')
;    String path to search for the simulation parameter file.
; LUN (default: -1)
;    Logical unit number for printing informational messages.
; AXES (default: 'xy')
;    String axes defining the data plane.
; RANGES (default: none)
;    Four-element integer array of the form [x0,xf,y0,yf] defining the
;    pre-rotation lower and upper bounds of the two logical axes. If
;    the user does not pass an appropriate array for this parameter,
;    this routine will define the array after it sets appropriate
;    values for the number of points along each logical axis.
; ROTATE (default: 0)
;    Integer multiple of 90 degrees by which to rotate the transformed
;    array (with optional transpose). See the man page for
;    IDL's rotate() for more information.
; DATA_ISFT (default: unset)
;    Boolean keyword indicating whether or not the target data is
;    EPPIC Fourier-transformed output.
;-
function import_plane_params, path=path, $
                              lun=lun, $
                              axes=axes, $
                              ranges=ranges, $
                              rotate=rotate, $
                              data_isft=data_isft

  ;;==Defaults and guards
  if n_elements(path) eq 0 then path = './'
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(rotate) eq 0 then rotate = 0

  ;;==Read simulation parameters
  params = set_eppic_params(path=path)

  ;;==Set differentials and E0 components
  case 1B of
     strcmp(axes,'xy') || strcmp(axes,'yx'): begin
        dx_out = params.dx
        dy_out = params.dy
        Ex0_out = params.Ex0_external
        Ey0_out = params.Ey0_external
        nx_out = params.nx*params.nsubdomains
        ny_out = params.ny
     end
     strcmp(axes,'xz') || strcmp(axes,'zx'): begin
        dx_out = params.dx
        dy_out = params.dz
        Ex0_out = params.Ex0_external
        Ey0_out = params.Ez0_external
        nx_out = params.nx*params.nsubdomains
        ny_out = params.nz
     end
     strcmp(axes,'yz') || strcmp(axes,'zy'): begin
        dx_out = params.dy
        dy_out = params.dz
        Ex0_out = params.Ey0_external
        Ey0_out = params.Ez0_external
        nx_out = params.ny
        ny_out = params.nz
     end
  endcase

  ;;==Rescale dx and dy if not FT data
  if ~keyword_set(data_isft) then begin
     dx_out *= params.nout_avg
     dy_out *= params.nout_avg
  endif

  ;;==Build x- and y-axis vectors
  if n_elements(ranges) ne 4 then ranges = [0,nx_out,0,ny_out]
  x_out = dx_out*(ranges[0] + indgen(nx_out))
  y_out = dy_out*(ranges[2] + indgen(ny_out))

  ;;==Rotate, if necessary
  if rotate gt 0 then begin
     if rotate mod 2 then begin
        tmp = y_out
        y_out = x_out
        x_out = tmp
        tmp = ny_out
        ny_out = nx_out
        nx_out = tmp
        tmp = dy_out
        dy_out = dx_out
        dx_out = tmp
     endif
     E0 = [Ex0_out,Ey0_out]
     rot_ang = rotate*90*!dtor
     rot_mat = [[+cos(rot_ang),+sin(rot_ang)], $
                [-sin(rot_ang),+cos(rot_ang)]]
     tmp = rot_mat # E0
     Ex0_out = tmp[0]
     Ey0_out = tmp[1]
  endif

  return, {x:x_out, $
           y:y_out, $
           nx:nx_out, $
           ny:ny_out, $
           dx:dx_out, $
           dy:dy_out, $
           Ex0:Ex0_out, $
           Ey0:Ey0_out}
end
