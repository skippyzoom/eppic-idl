;+
; Get the file extension of a given file name.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NAME (required)
;    String file name from which to get extension.
; <return> (string)
;    File extension starting after the last dot (e.g., 'pdf'
;    for a file named 'file.pdf')
;-
function get_extension, name
  name_in = name
  n = n_elements(name_in)
  if n gt 1 then begin 
     ext = strarr(n)
     for i=0,n-1 do begin
        pos = strpos(name_in[i],'.',/reverse_search)
        ext[i] = strmid(name_in[i],pos+1,strlen(name_in[i]))
     endfor
  endif $
  else begin
     pos = strpos(name_in,'.',/reverse_search)
     ext = strmid(name_in,pos+1,strlen(name_in))
  endelse

  return, ext
end
