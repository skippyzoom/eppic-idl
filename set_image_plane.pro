function set_image_plane, fdata, $
                          ranges=ranges, $
                          zero_point=zero_point, $
                          axes=axes, $
                          rotate=rotate, $
                          params=params, $
                          path=path
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

  ;;==Check ranges
  ranges = set_ranges(ranges,params=params,path=path)

  ;;==Get dimensions of data array
  fsize = size(fdata)
  ndim = fsize[0]
  nx = fsize[1]
  ny = fsize[2]
  if ndim eq 4 then nz = fsize[3]
  nt = fsize[ndim]

  ;;==Declare the output dictionary
  plane = dictionary()

  ;;==Set plane-specific variables
  case 1B of
     strcmp(axes,'xy'): begin
        plane['dx'] = params.dx*params.nout_avg
        plane['dy'] = params.dy*params.nout_avg
        plane['x'] = plane.dx*(ranges.x0 + indgen(nx))
        plane['y'] = plane.dy*(ranges.y0 + indgen(ny))
        ;; if ndim eq 3 then plane['f'] = fdata $
        ;; else plane['f'] = reform(fdata[*,*,zero_point,*])
        if ndim eq 4 then fdata = reform(fdata[*,*,zero_point,*])
     end
     strcmp(axes,'xz'): begin
        plane['dx'] = params.dx*params.nout_avg
        plane['dy'] = params.dz*params.nout_avg
        plane['x'] = plane.dx*(ranges.x0 + indgen(nx))
        plane['y'] = plane.dz*(ranges.z0 + indgen(nz))
        ;; if ndim eq 3 then plane['f'] = fdata $
        ;; else plane['f'] = reform(fdata[*,zero_point,*,*])
        if ndim eq 4 then fdata = reform(fdata[*,zero_point,*,*])
     end
     strcmp(axes,'yz'): begin
        plane['dx'] = params.dy*params.nout_avg
        plane['dy'] = params.dz*params.nout_avg
        plane['x'] = plane.dy*(ranges.y0 + indgen(ny))
        plane['y'] = plane.dz*(ranges.z0 + indgen(nz))
        ;; if ndim eq 3 then plane['f'] = fdata $
        ;; else plane['f'] = reform(fdata[zero_point,*,*,*])
        if ndim eq 4 then fdata = reform(fdata[zero_point,*,*,*])
     end
  endcase

  ;;==Retain singular time dimension
  if nt eq 1 then fdata = reform(fdata, $
                                 [size(fdata,/dim),1])

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
