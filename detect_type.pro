;+
; Detect the original type of a variable read from a file.
;
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; VAR (required)
;    Target variable.
; CONVERT (default: unset)
;    If set, convert the value in VAR to float or int.
; DOUBLE (default: unset)
;    If set and CONVERT is set, convert VAR to double-precision float.
; LONG (default: unset)
;    If set and CONVERT is set, convert VAR to long-word integer.
; <return>
;    The variable type, or the converted variable.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- The order of the CASE block matters. Placing the ' '
;    condition before the '.' condition ensures that this
;    function won't mistake strings with periods for floats;
;    similar logic holds for floats/exponentials.
;-
function detect_type, var,convert=convert,double=double,long=long

  ;;==Check for request to convert
  if keyword_set(convert) then begin ;Convert to numerical type
     case 1 of
        ;;==This is a string
        (strpos(var,' ') ge 0): value = var
        ;;==This is an exponential
        (strpos(var,'e') ge 0): begin
           if keyword_set(double) then value = double(var) $
           else value = float(var)
        end
        ;;==This is a float
        (strpos(var,'.') ge 0): begin
           if keyword_set(double) then value = double(var) $
           else value = float(var)
        end
        ;;==This is an int
        else: begin
           if keyword_set(long) then value = long(var) $
           else value = fix(var)
        end
     endcase

     ;;==Return numerical value
     return, value
  endif $
  else begin                    ;Do not convert

     ;;==Set default type to integer
     type = 'int'
     case 1 of
        ;;==This is a string
        (strpos(var,' ') ge 0): type = 'string'
        ;;==This is an exponential
        (strpos(var,'e') ge 0): type = 'exponential'
        ;;==This is a float or double
        (strpos(var,'.') ge 0): type = 'float'
     endcase

     ;;==Return variable type
     return, type
  endelse

end
