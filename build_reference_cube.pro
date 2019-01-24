;+
; Builds a logically 2-D or 3-D object that read_ph5_cube.pro can use
; to set dimensions for data reading.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NDIM_SPACE (required)
;    Integer number of spatial dimensions. 
; DATA_ISFT (default: 0)
;    Boolean that represents whether the EPPIC data quantity is
;    Fourier-transformed or not.
; PATH (default: './')
;    Path in which to search for EPPIC parameter file if not is supplied.
; PARAMS (default: empty)
;    Dictionary of EPPIC simulation parameters as returned by
;    set_eppic_params().
; RANGES (default: [0,nx,0,ny[,0,nz]])
;    A four- or six-element array specifying logical x and y ranges
;    to return. The elements are [x0,xf,y0,yf[,z0,zx]], where 
;    x0 and xf are the bounds of the first dimension, y0 and yf are
;    the bounds of the second dimension, and z0 and zf are the bounds
;    of the third dimension, if applicable.
; NORMAL (default: unset)
;    If set, indicates that ranges are normalized to simulation dimensions.
; <return> (dictionary)
;    The reference dimensions and related information.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- The 2-D case is identical to that in
;    build_reference_plane.pro. It exists here because
;    read_ph5_cube.pro is designed as a unified interface for EPPIC
;    runs with 2 or 3 spatial dimensions. 
;-
function build_reference_cube, ndim_space, $
                               data_isft=data_isft, $
                               path=path, $
                               params=params, $
                               ranges=ranges, $
                               normal=normal

  if n_elements(path) eq 0 then path = './'
  if n_elements(params) eq 0 then $
     params = set_eppic_params(path=path)

  case ndim_space of 
     2: begin
        nx = params.nx*params.nsubdomains
        ny = params.ny
        if n_elements(ranges) eq 0 then ranges = [0,nx,0,ny]
        if keyword_set(normal) then begin
           x0 = ranges[0]*nx
           xf = ranges[1]*nx
           y0 = ranges[2]*ny
           yf = ranges[3]*ny
        endif $
        else begin
           x0 = ranges[0]
           xf = ranges[1]
           y0 = ranges[2]
           yf = ranges[3]
        endelse
        ind_x = 0
        ind_y = 1
        h5_start = [x0,y0]
        h5_count = [xf,yf]
     end
     3: begin
        nx = params.nx*params.nsubdomains
        ny = params.ny
        nz = params.nz
        if n_elements(ranges) eq 0 then ranges = [0,nx,0,ny,0,nz]
        if keyword_set(normal) then begin
           x0 = ranges[0]*nx
           xf = ranges[1]*nx
           y0 = ranges[2]*ny
           yf = ranges[3]*ny
           z0 = ranges[4]*nz
           zf = ranges[5]*nz
        endif $
        else begin
           x0 = ranges[0]
           xf = ranges[1]
           y0 = ranges[2]
           yf = ranges[3]
           z0 = ranges[4]
           zf = ranges[5]
        endelse
        ind_x = 0
        ind_y = 1
        ind_z = 2
        h5_start = [x0,y0,z0]
        h5_count = [xf,yf,zf]
     end
  endcase

  return, dictionary('nx',nx, $
                     'ny',ny, $
                     'nz',nz, $
                     'x0',x0, $
                     'xf',xf, $
                     'y0',y0, $
                     'yf',yf, $
                     'z0',z0, $
                     'zf',zf, $
                     'ind_x',ind_x, $
                     'ind_y',ind_y, $
                     'ind_z',ind_z, $
                     'h5_start',reverse(h5_start), $
                     'h5_count',reverse(h5_count))
end
