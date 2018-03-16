;+
; Build the fully qualified path(s) for analyzing
; EPPIC data in a given project directory.
;-
function set_project_path, base,proj,local

  n_local = n_elements(local)
  path = strarr(n_local)
  sep = path_sep()
  for id=0,n_local-1 do $
     path[id] = expand_path(base+sep+proj+sep+local[id])

  return, path
end
