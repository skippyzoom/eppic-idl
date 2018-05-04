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
;    String file name or array of string file names from which to
;    strip extension.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This function will return NAME unmodified if it does not find an
;    extension. This allows the user to call this function to ensure
;    that certain file names have no extension, or to call this
;    function recursively, without fear of mangling the base name.
;-
function strip_extension, name
  name_in = name
  n = n_elements(name_in)
  for i=0,n-1 do begin
     pos = strpos(name_in[i],'.',/reverse_search)
     if pos ge 0 then name_in[i] = strmid(name_in[i],0,pos)
  endfor
  return, name_in
end
