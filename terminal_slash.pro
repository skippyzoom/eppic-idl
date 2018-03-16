;+
; Returns the path with a terminal '/'
;-
function terminal_slash, path

  pathLen = strlen(path)
  termChar = strmid(path,pathLen-1)
  if strcmp(termChar,'/') eq 0 then $
     path += '/'

  return, path
end
