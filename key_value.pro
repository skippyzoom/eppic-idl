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
; OBJ (required)
;    The dictionary or hash to query.
; KEY (required)
;    The key within OBJ to check.
; VALUE (default: 1B)
;    The value against which to check KEY. The default value allows
;    the user to call this function to work like keyword_set().
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; <return> (boolean)
;    Truth value of query.
;-
function key_value, obj,key,value=value,lun=lun

  ;;==Set default lun
  if n_elements(lun) eq 0 then lun = -1

  ;;==Set default reference value to 1 (true)
  if n_elements(value) eq 0 then value = 1B

  ;;==Set default return value to false
  ret = 0B
  
  ;;==If obj is a dictionary or hash, check key against value;
  ;;  otherwise, issue a warning message
  if isa(obj,'dictionary') || isa(obj,'hash') then begin

     ;;==Check key against value based on type
     case 1B of
        isa(value,/number): ret = obj.haskey(key) && obj[key] eq value
        isa(value,/string): ret = obj.haskey(key) && strcmp(obj[key],value)
        else: printf, lun,"[KEY_VALUE] Could not recognized type"
     endcase

  endif $
  else printf, lun, "[KEY_VALUE] Warning: Input is not a dictionary or hash."

  ;;==Return the truth value
  return, ret
end
