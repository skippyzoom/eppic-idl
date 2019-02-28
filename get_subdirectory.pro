;+
; Extract the local subdirectory.
;
; This function extracts the local subdirectory from a given path. If
; the user does not specify a path, this function uses the current
; working path. If the user specifies the path with a terminal '/',
; this function trims the terminal '/'. For example:
; get_subdirectory('/my/full/path') and
; get_subdirectory('/my/full/path/') both return 'path'. 
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (default: current working path)
;    The path from which to derive the local subdirectory.
; <return> (string)
;    The most local subdirectory in the path.
;-
function get_subdirectory, path
  
  ;;==Get current working path by default
  if n_elements(path) eq 0 then spawn, 'pwd',path

  ;;==Determine number of paths
  n_paths = n_elements(path)

  ;;==Loop over paths
  for ip=0,n_paths-1 do begin

     ;;==Find location of terminal '/' character
     last_slash = strpos(path[ip],'/',/reverse_search)

     ;;==Determine path length
     path_len = strlen(path[ip])

     ;;==Trim the terminal slash
     if last_slash eq path_len-1 then begin
        path[ip] = strmid(path[ip],0,path_len-1)
        last_slash = strpos(path[ip],'/',/reverse_search)
     endif

  endfor
  
  ;;==Return the most local subdirectory(s)
  return, strmid(path,last_slash+1,path_len)

end
