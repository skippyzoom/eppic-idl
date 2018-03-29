;+
; Extract the local subdirectory.
;
; This function extracts the local subdirectory from a given
; path. If the user does not specify a path, this function 
; uses the current working path. If the user specifies the 
; path with a terminal '/', this function trims the terminal 
; '/'. For example: get_subdirectory('/my/full/path') and 
; get_subdirectory('/my/full/path/') both return 'path'.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (default: current working path)
;    The path from which to derive the local subdirectory.
; <return>
;    The most local subdirectory in the path.
;-
function get_subdirectory, path
  
  ;;==Get current working path
  if n_elements(path) eq 0 then spawn, 'pwd',path

  ;;==Find location of terminal '/' character
  last_slash = strpos(path,'/',/reverse_search)

  ;;==Determine path length
  path_len = strlen(path)

  ;;==Trim the terminal slash
  if last_slash eq path_len-1 then begin
     path = strmid(path,0,path_len-1)
     last_slash = strpos(path,'/',/reverse_search)
  endif
  
  ;;==Return the most local subdirectory
  return, strmid(path,last_slash+1,path_len)
end
