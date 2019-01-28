;+
; Function to check the existence and value of a dictionary or hash
; key.
;
; This function returns 1 (true) if the dictionary/hash exists, the
; dictionary/hash contains the requested key, and the key has the given
; value. Otherwise, it returns 0 (false)
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; D (required)
;    The dictionary or hash to query.
; K (required)
;    The key within D to check.
; V (required)
;    The value against which to check K.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; <return> (boolean)
;    Truth value of query.
;-
function key_value, d,k,v,lun=lun

  ;;==Set default lun
  if n_elements(lun) eq 0 then lun = -1

  ;;==Set default return value to false
  r = 0B
  
  ;;==If d is a dictionary or hash, check k against v;
  ;;  otherwise, issue a warning message
  if isa(d,'dictionary') || isa(d,'hash') then begin

     ;;==Check key against value based on type
     case 1B of
        isa(v,/number): r = d.haskey(k) && d[k] eq v
        isa(v,/string): r = d.haskey(k) && strcmp(d[k],v)
        else: printf, lun,"[KEY_VALUE] Could not recognized type"
     endcase

  endif $
  else printf, lun, "[KEY_VALUE] Warning: Input is not a dictionary or hash."

  ;;==Return the truth value
  return, r
end
