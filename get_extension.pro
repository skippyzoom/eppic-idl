;+
; Get the file extension of a given file name.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NAME (required)
;    String file name, or array of names, from which to get
;    extension. 
; <return> (string or string array)
;    File extension starting after the last dot (e.g., 'pdf'
;    for a file named 'file.pdf')
;-
function get_extension, name

  ;;==Protect input
  name_in = name

  ;;==Get number of input strings
  n = n_elements(name_in)

  ;;==Check for single string or array
  if n gt 1 then begin 

     ;;==Set up output array
     ext = strarr(n)

     ;;==Loop over strings
     for i=0,n-1 do begin

        ;;==Find the position of the final dot
        pos = strpos(name_in[i],'.',/reverse_search)

        ;;==Extract the characters after the dot
        ext[i] = strmid(name_in[i],pos+1,strlen(name_in[i]))

     endfor
  endif $
  else begin

     ;;==Find the position of the final dot
     pos = strpos(name_in,'.',/reverse_search)

     ;;==Extract the characters after the dot
     ext = strmid(name_in,pos+1,strlen(name_in))
  endelse

  ;;==Return the string(s)
  return, ext
end
