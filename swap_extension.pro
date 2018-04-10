;+
; Swap the extension on a file. 
;
; This function swaps one extension for another in a file name (e.g.,
; converts 'file.pdf' to 'file.png') It calls the IDL function
; file_basename.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NAME (required)
;    String file name from which to strip extension.
; CUR_EXT (required)
;    The current extension. file_basename uses this value to determine
;    the substring to remove from NAME.
; NEW_EXT (required)
;    The new extension.
;-
function swap_extension, name,cur_ext,new_ext
  return, file_basename(name,cur_ext)+new_ext
end
