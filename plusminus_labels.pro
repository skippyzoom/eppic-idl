;+
; Create an array of labels with appropriate +/- symbols
;
; This function returns an array of numerical labels with '+'
; prefix for positive values and a '-' prefix for negative values,
; using the 'f+...' format specifier with special treatment of '0'.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; VALUES (requires)
;    An array of numerical values for which to make string labels.
; FORMAT (default: 'f8.3')
;    Optional user-specified FORTRAN-style format code. See 
;    https://harrisgeospatial.com/docs/format_codes_fortran.html
;    for details. If the user passes a string with leading or 
;    training parentheses, this function will strip them to access 
;    the code and width. This function will also add 1 to the width 
;    to account for the +/- symbol, so that the printed numbers have 
;    the user-specified width.
;-
function plusminus_labels, values,format=format

  ;;==Defaults and guards
  if n_elements(format) eq 0 then format = 'f8.3'

  ;;==Strip parentheses
  length = strlen(format)
  if strcmp(strmid(format,0,1),'(') then $
     format = strmid(format,1,length-1)
  length = strlen(format)
  if strcmp(strmid(format,0,1,/reverse),')') then $
     format = strmid(format,0,length-1)

  ;;==Extract format code and width
  length = strlen(format)
  code = strmid(format,0,1)
  width = strmid(format,1,length-1)
  if width gt 1 then begin
     dot = strpos(width,'.')
     if dot ge 0 then $
        width = strcompress(strmid(width,0,dot)+1,/remove_all)+ $
                '.'+ $
                strcompress(strmid(width,dot+1,strlen(width)),/remove_all) $
     else width = strcompress(width+0,/remove_all)
  endif

  ;;==Create labels
  labels = string(values,format='('+code+'+'+width+')')
  iEq0 = where(values eq 0.0,count)
  if count gt 0 then labels[iEq0] = string(0,format='('+format+')')
  labels = strcompress(labels,/remove_all)

  return, labels
end
