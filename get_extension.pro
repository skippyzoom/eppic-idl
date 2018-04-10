;+
; Get the file extension of a given file name.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NAME (required)
;    String file name from which to get extension.
; <return>
;    String file extension starting after the last dot (e.g., 'pdf'
;    for a file named 'file.pdf')
;-
function get_extension, name
  name_in = name
  pos = strpos(name_in,'.',/reverse_search)
  ext = strmid(name_in,pos+1,strlen(name_in))
  return, ext
end
