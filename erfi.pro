;+
; Imaginary error function.
;
; This function calculates the imaginary error function, defined by
; erfi(z) = -i*erf(i*z), where erf() is IDL's built-in error
; function. 
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; Z (required)
;    Argument to the complex error function. May be real or
;    complex. May be a scalar or a vector.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; <return> (type of Z)
;    Result of the imaginary error function of Z. If Z is a scalar,
;    this will be a scalar; if Z is a vector, this will be a vector
;    with each entry equal to the imaginary error function of
;    the corresponding entry in Z. If Z is neither real nor complex
;    (e.g., a string), this function alerts the user and returns
;    !NULL.
;-
function erfi,z,lun=lun

  ;;==Default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Check type of Z
  case size(z,/type) of
     4: begin                   ;Z is real
        r = imaginary(signum(z)*erf(complex(0,z)))
        if size(z,/n_dim) eq 0 then r = r[0]
     end
     6: begin                   ;Z is complex
        w = complex(-imaginary(z),real_part(z))
        r = complex(imaginary(erf(w)),-real_part(erf(w)))
        if size(z,/n_dim) eq 0 then r = r[0]
     end
     else: begin                ;Z is neither (error)
        msg = "[ERFI] Z may be real or complex."
        printf, lun,msg
        r = !NULL
     end
  endcase

  return, r
end
