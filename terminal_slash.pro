;+
; Returns the path with a terminal '/'. If the input path ends in '/',
; this function will have no effect.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (required)
;    String path to update.
; <return> (string)
;    Updated path.
;-
function terminal_slash, path

  ;;==Determine the path length
  path_len = strlen(path)

  ;;==Extract the terminal character
  term_char = strmid(path,path_len-1)

  ;;==If the terminal character is not '/', add it
  if strcmp(term_char,'/') eq 0 then path += '/'

  ;;==Return the new path
  return, path
end
