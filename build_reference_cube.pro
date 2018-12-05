function build_reference_cube, ndim_space, $
                               data_isft=data_isft, $
                               ranges=ranges, $
                               path=path, $
                               params=params, $
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
