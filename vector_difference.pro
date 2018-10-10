;+
; Calculate the differece of two vectors, and return components in
; both Cartesian and polar coordinates.
;
; Created by Matt Young
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; V1X (required)
;    X component of first vector.
; V2X (required)
;    X component of second vector.
; V1Y (required)
;    Y component of first vector.
; V2Y (required)
;    Y component of second vector.
; V1Z (optional)
;    Z component of first vector.
; V2Z (optional)
;    Z component of second vector.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; QUIET (default: unset)
;    Do not print runtime messages
; <return>
;    Dictionary containing the appropriate 2-D or 3-D vector
;    components, if the function succeeded, or
;    !NULL if it didn't.  Since !NULL has zero elements, the 
;    user can check the number of elements of the return value before 
;    proceeding.
;-
function vector_difference, v1x,v2x,v1y,v2y,v1z,v2z, $
                            lun=lun, $
                            quiet=quiet

  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Determine number of dimensions
  ndim = 2+(n_elements(v1z) ne 0 && n_elements(v2z) ne 0)

  ;;==Calculate vector difference and return component dictionary
  case ndim of
     2: begin
        vdx = v1x-v2x
        vdy = v1y-v2y
        return, dictionary('x', vdx, $
                           'y', vdy, $
                           'r', sqrt(vdx^2 + vdy^2 + vdz^2), $
                           't', atan(vdy,vdx))        
     end
     3: begin
        vdx = v1x-v2x
        vdy = v1y-v2y
        vdz = v1z-v2z
        return, dictionary('x', vdx, $
                           'y', vdy, $
                           'z', vdz, $
                           'r', sqrt(vdx^2 + vdy^2 + vdz^2), $
                           't', atan(vdy,vdx), $
                           'p', atan(vdz,sqrt(vdx^2+vdy^2)))
     end
     else: begin
        if ~keyword_set(quiet) then $
           printf, lun,"[DRIFT_VELOCITY] Incorrect number of arguments"
        return, !NULL
     end
  endcase

end
