;+
; Remove the extension from a file name.
;
; This function removes the extension from a file name without knowing
; the extension a priori. It assumes that all characters following the
; final '.' comprise the extension.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NAME (required)
;    String file name from which to strip extension.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This function will return NAME unmodified if it does not find an
;    extension.
;-
function strip_extension, name
  name_in = name
  pos = strpos(name_in,'.',/reverse_search)
  if pos ge 0 then name_in = strmid(name_in,0,pos)
  return, name_in
end
