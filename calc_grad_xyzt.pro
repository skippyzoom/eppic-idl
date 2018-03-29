;+
; Calculate a time-dependent vector field from a scalar 
; potential and optionally scale by a constant (F = c*Grad[f]).
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA (required)
;    The scalar function from which to calculate the gradient.
; DX, DY, DZ (default: 1.0 for all)
;    Differentials for each dimension. This function will pass
;    these values to the gradient function.
; SCALE (default: 1.0)
;    A scalar value by which to scale each gradient component.
; VERBOSE (default: unset)
;    Print runtime messages.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; <return>
;    A struct containing the components of the optionally scaled
;    gradient of data.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This function checks that 'scale' is not zero before 
;    proceeding, which allows the user to bypass this function
;    at runtime by providing scale = 0
; -- This function requires a gradient function. It currently
;    uses ~/idl/pro/gradient.pro, which returns a dictionary
;    with elements x, y, and z, representing the 1-D derivative
;    in each dimension.
;-
function calc_grad_xyzt, data, $
                           dx=dx,dy=dy,dz=dz, $
                           scale=scale, $
                           verbose=verbose, $
                           lun=lun
  ;;==Set default scale
  if n_elements(scale) eq 0 then scale = 1.0

  ;;==Check value of scale
  if scale ne 0 then begin

     ;;==Other defaults and guards
     if n_elements(lun) eq 0 then lun = -1
     if n_elements(dx) eq 0 then dx = 1.0
     if n_elements(dy) eq 0 then dy = 1.0
     if n_elements(dz) eq 0 then dz = 1.0

     ;;==Get dimensions
     data = reform(data)
     dsize = size(data)
     n_dims = dsize[0]
     nt = dsize[dsize[0]]

     ;;==Set up component arrays
     switch n_dims of
        3: Fz = make_array(size(data,/dim), $
                           type = size(data,/type), $
                           value = 0)
        2: Fy = make_array(size(data,/dim), $
                           type = size(data,/type), $
                           value = 0)
        1: Fx = make_array(size(data,/dim), $
                           type = size(data,/type), $
                           value = 0)
     endswitch

     ;;==Echo parameters
     if keyword_set(verbose) then begin
        printf, lun,"[CALC_GRAD_XYZT] Calculating F = c*Grad[f] ", $
               "(dx = ",strcompress(string(dx,format='(e10.4)'), $
                                    /remove_all), $
               ",", $
               " dy = ",strcompress(string(dy,format='(e10.4)'), $
                                    /remove_all), $
               ",", $
               " dz = ",strcompress(string(dy,format='(e10.4)'), $
                                    /remove_all),")"
     endif

     ;;==Calculate F = c*Grad[f]
     for it=0L,nt-1 do begin
        case n_dims of
           3: begin
              gradf = gradient(data[*,*,it],dx=dx,dy=dy)
              Fx[*,*,it] = scale*gradf.x
              Fy[*,*,it] = scale*gradf.y
              ;; vecF = dictionary('x',Fx,'y',Fy)
              vecF = {x:Fx, y:Fy}
           end
           4: begin
              gradf = gradient(data[*,*,*,it],dx=dx,dy=dy,dz=dz)
              Fx[*,*,*,it] = scale*gradf.x
              Fy[*,*,*,it] = scale*gradf.y
              Fz[*,*,*,it] = scale*gradf.z
              ;; vecF = dictionary('x',Fx,'y',Fy,'z',Fz)
              vecF = {x:Fx, y:Fy, z:Fz}
           end
        endcase
     endfor

     return, vecF

  endif ;; scale != 0
end
