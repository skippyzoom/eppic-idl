function build_reference_plane, axes, $
                                ndim_space, $
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
        if ~keyword_set(data_isft) then begin
           x0 /= params.nout_avg
           xf /= params.nout_avg
           y0 /= params.nout_avg
           yf /= params.nout_avg
        endif
        ind_x = 0
        ind_y = 1
        h5_start = [x0,y0]
        h5_count = [xf,yf]
     end
     3: begin
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
              if ~keyword_set(data_isft) then begin
                 x0 /= params.nout_avg
                 xf /= params.nout_avg
                 y0 /= params.nout_avg
                 yf /= params.nout_avg
              endif
              ind_x = 0
              ind_y = 1
              h5_start = [x0,y0,0]
              h5_count = [xf,yf,1]
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
              if ~keyword_set(data_isft) then begin
                 x0 /= params.nout_avg
                 xf /= params.nout_avg
                 y0 /= params.nout_avg
                 yf /= params.nout_avg
              endif
              ind_x = 0
              ind_y = 2
              h5_start = [x0,0,y0]
              h5_count = [xf,1,yf]
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
              if ~keyword_set(data_isft) then begin
                 x0 /= params.nout_avg
                 xf /= params.nout_avg
                 y0 /= params.nout_avg
                 yf /= params.nout_avg
              endif
              ind_x = 1
              ind_y = 2
              h5_start = [0,x0,y0]
              h5_count = [1,xf,yf]
           end
        endcase
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
                     'h5_start',reverse(h5_start), $
                     'h5_count',reverse(h5_count))
end
