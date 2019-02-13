;+
; Signum function.
;
; This function returns the sign of the input value. There is also an
; IDL built-in signum.pro, introduced in 8.3. This function and the
; built-in handle complex numbers differently.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; X (required)
;    Number of which to determine the sign.
; <return> (type of X)
;    -1, 0, or +1 if X is finite, +/-NaN if X is NaN, or +/-Inf if X
;    is Inf.
;-
function signum, x

  ;;==Determine the number of elements in X.
  n = n_elements(x)

  ;;==Allocate a return array.
  sgn = make_array(n,type=size(x,/type))

  ;;==Loop over elements of X
  for i=0,n-1 do begin

     ;;==Check possible cases for X
     case 1 of
        x[i] eq 0: sgn[i] = 0
        finite(x[i],/infinity,sign=1): sgn[i] = !values.f_infinity
        finite(x[i],/infinity,sign=-1): sgn[i] = -!values.f_infinity
        finite(x[i],/nan,sign=1): sgn[i] = !values.f_nan
        finite(x[i],/nan,sign=-1): sgn[i] = -!values.f_nan
        else: begin 
           if size(x[i],/type) eq 6 then begin
              rp = real_part(x[i])
              ip = imaginary(x[i])
              sgn[i] = complex(rp/abs(rp),ip/abs(ip))
           endif else $
              sgn[i] = x[i]/abs(x[i])
        end
     endcase

  endfor

  ;;==Return a scalar if X has one element
  if n eq 1 then sgn = sgn[0]
  return, sgn

end
