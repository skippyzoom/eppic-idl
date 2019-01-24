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
; <return> (struct)
;    The components of the optionally scaled gradient of DATA.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This function checks that 'scale' is not zero before 
;    proceeding, which allows the user to bypass this function
;    at runtime by providing scale = 0
; -- This function requires a gradient function. It currently
;    uses ~/idl/eppic/gradient.pro, which returns a dictionary
;    whose elements represent the 1-D derivative in each dimension.
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

     ;;==Check for single time step
     dsize = size(data)
     single_ts = 0B
     if dsize[dsize[0]] eq 1 then single_ts = 1B

     ;;==Remove singular spatial dimensions
     data = reform(data)
     if single_ts then data = reform(data,[size(data,/dim),1])

     ;;==Update dimensional info
     n_dims = size(data,/n_dim)
     d_dims = size(data,/dim)
     d_type = size(data,/type)

     ;;==Get number of time steps
     nt = dsize[dsize[0]]

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
     case n_dims of
        3: begin
           Fy = make_array(d_dims, $
                           type = d_type, $
                           value = 0)
           Fx = make_array(d_dims, $
                           type = d_type, $
                           value = 0)
           for it=0L,nt-1 do begin
              gradf = gradient(data[*,*,it],dx=dx,dy=dy)
              Fx[*,*,it] = scale*gradf.x
              Fy[*,*,it] = scale*gradf.y
           endfor
           vecF = {x:Fx, y:Fy}
        end
        4: begin
           Fz = make_array(d_dims, $
                           type = d_type, $
                           value = 0)
           Fy = make_array(d_dims, $
                           type = d_type, $
                           value = 0)
           Fx = make_array(d_dims, $
                           type = d_type, $
                           value = 0)
           for it=0L,nt-1 do begin
              gradf = gradient(data[*,*,*,it],dx=dx,dy=dy,dz=dz)
              Fx[*,*,*,it] = scale*gradf.x
              Fy[*,*,*,it] = scale*gradf.y
              Fz[*,*,*,it] = scale*gradf.z
           endfor
           vecF = {x:Fx, y:Fy, z:Fz}
        end
     endcase

     return, vecF

  endif ;; scale != 0
end
