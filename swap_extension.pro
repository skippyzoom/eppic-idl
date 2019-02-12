;+
; Swap a file extension.
;
; This function swaps one extension for another in a file name (e.g.,
; converts 'file.pdf' to 'file.png'). It calls the IDL function
; file_basename.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NAME (required)
;    String file name from which to strip extension.
; NEW_EXT (required)
;    The new extension. This function will trim the leading dot, if
;    necessary, to prevent returning names such as 'file..ext'.
; CURRENT (default: unset)
;    The current extension. file_basename uses this value to determine
;    the substring to remove from NAME. If the user does not provide a
;    string for the current extension, this function will guess it
;    by get_extension.pro. Providing CURRENT is helpful for file names
;    that contain periods (e.g., 'file.name.ext'). 
; <return> (string)
;    New file name.
;-
function swap_extension, name,new_ext, $
                         lun=lun, $
                         quiet=quiet, $
                         current=current

  ;;==If CURRENT exists, make sure it is a string.
  ;;  If it doesn't, naively determine the extension.
  if keyword_set(current) then begin
     if ~isa(current,/string) then begin
        msg = "[SWAP_EXTENSION] CURRENT must be a string."
        if ~keyword_set(quiet) then printf, lun,msg
     endif
  endif $
  else current = get_extension(name)

  ;;==Strip leading dot from CURRENT, if it exists.
  current = get_extension(current)

  ;;==Return the base name with the new extension.
  return, file_basename(name,current)+get_extension(new_ext)
end
