;+
; Find the array value closest to target value. This is similar
; to IDL's value_locate.pro, which requires that the search
; vector (called ARRAY, here) is monotonic.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; ARRAY (required)
;    Numerical array to which this function will compare each element
;    of TARGET. 
; TARGET (required)
;    Numerical array of values for which the user wants to closest
;    value in ARRAY.
; DOUBLE (default: unset)
;    Set this keyword to perform the calculation in double precision.
; <return> (long integer or array)
;    Index or indices into ARRAY, giving the location of the value of
;    ARRAY closest to the corresponding value of TARGET. If the user
;    fails to supply ARRAY and TARGET, this function will return !NULL.
;-

function find_closest, array,target, $
                       lun=lun, $
                       quiet=quiet, $
                       double=double

  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Make sure ARRAY and TARGET exist
  if n_params() eq 2 then begin

     ;;==Ensure double precision, if requested
     if keyword_set(double) then begin
        array = double(array)
        target = double(target)
     endif

     ;;==Get number of target values
     n = n_elements(target)

     ;;==Find the location of closest value for each target value
     imin = lonarr(n)
     for i=0,n-1 do begin
        abs_diff = abs(array-target[i])
        min_val = min(abs_diff,tmp)
        imin[i] = tmp
     endfor

     ;;==Return a scalar if there's only one target value
     if n eq 1 then imin = imin[0]
     return, imin

  endif $
  else begin

     ;;==Warn the user of incorrect input and return
     msg = "[FIND_CLOSEST] "+ $
           "Please supply ARRAY and TARGET."
     if ~keyword_set(quiet) then printf, lun,msg
     return, !NULL

  endelse

end
