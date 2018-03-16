;+
; Detect the original type of a variable read from a file.
;
; NOTES
; -- The order of the CASE block matters. Placing the ' '
;    condition before the '.' condition ensures that this
;    function won't mistake strings with periods for floats;
;    similar logic holds for floats/exponentials.
;-
function detect_type, var,convert=convert,double=double,long=long

  if keyword_set(convert) then begin
     case 1 of
        (strpos(var,' ') ge 0): value = var
        (strpos(var,'e') ge 0): begin
           if keyword_set(double) then value = double(var) $
           else value = float(var)
        end
        (strpos(var,'.') ge 0): begin
           if keyword_set(double) then value = double(var) $
           else value = float(var)
        end
        else: begin
           if keyword_set(long) then value = long(value) $
           else value = fix(var)
        end
     endcase
     return, value
  endif $
  else begin
     type = 'int'
     case 1 of
        (strpos(var,' ') ge 0): type = 'string'
        (strpos(var,'e') ge 0): type = 'exponential'
        (strpos(var,'.') ge 0): type = 'float'
     endcase
     return, type
  endelse

end
