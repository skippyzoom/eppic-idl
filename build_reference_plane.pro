function build_reference_plane, axes, $
                                ranges=ranges, $
                                path=path, $
                                params=params, $
                                normal=normal

  if n_elements(path) eq 0 then path = './'
  if n_elements(params) eq 0 then $
     params = set_eppic_params(path=path)

  case 1B of
     strcmp(axes,'xy') || strcmp(axes,'yx'): begin
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
        h5_start = [x0,y0,0]
        h5_count = reverse([xf,yf,1])
     end
     strcmp(axes,'xz') || strcmp(axes,'zx'): begin
        nx = params.nx*params.nsubdomains
        ny = params.nz
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
        ind_y = 2
        h5_start = [x0,0,y0]
        h5_count = reverse([xf,1,yf])
     end
     strcmp(axes,'yz') || strcmp(axes,'zy'): begin
        nx = params.ny
        ny = params.nz
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
        ind_x = 1
        ind_y = 2
        h5_start = [0,x0,y0]
        h5_count = reverse([1,xf,yf])
     end
  endcase

  return, dictionary('nx',nx, $
                     'ny',ny, $
                     'x0',x0, $
                     'xf',xf, $
                     'y0',y0, $
                     'yf',yf, $
                     'ind_x',ind_x, $
                     'ind_y',ind_y, $
                     'h5_start',h5_start, $
                     'h5_count',h5_count)
end
