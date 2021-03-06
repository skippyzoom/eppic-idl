;+
; Calculate the centroid (center-of-mass) of a 2-D array
;
; Created by Matt Young, based on David Fanning's function of
; the same name. See http://www.idlcoyote.com/tips/centroid.html
; (current as of 28Sep2018).
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; ARRAY (required)
;    A 2-D array from which to calculate the centroid.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; QUIET (default: unset)
;    Do not print runtime messages
; VARIANCE (default: unset)
;    A named two-element vector that will contain the mean squared
;    variance in the centroid
; <return> (floating point array)
;    Two values giving the (x,y) coordinates of the center of mass, if
;    the function succeeded, or !NULL if it didn't.  Since
;    !NULL has zero elements, the user can check the number of
;    elements of the return value before proceeding. 
;-
function centroid, array, $
                   lun=lun, $
                   quiet=quiet, $
                   variance=variance

  ;;==Set the default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Check for correct number of dimensions
  if size(array,/n_dim) eq 2 then begin

     ;;==Get array dimensions
     asize = size(array)
     nx = asize[1]
     ny = asize[2]

     ;;==Create x and y vectors
     x = indgen(nx)
     y = indgen(ny)

     ;;==Calculate total mass
     total_mass = total(array)

     ;;==Approximate integrals for (x,y) of centroid
     xcm = total(total(array,2)*x)/total_mass
     ycm = total(total(array,1)*y)/total_mass

     ;;==Approximate integrals for variance in centroid
     if keyword_set(variance) then begin
        s2x = total(total(array,2)*(x-xcm)^2)/total_mass
        s2y = total(total(array,1)*(y-ycm)^2)/total_mass
        variance = [s2x,s2y]
     endif
     ;;==Return (x,y) of centroid
     return, [xcm,ycm]
  endif $
  else begin

     ;;==Let the user know of incorrect number of dimensions
     if ~keyword_set(quiet) then $
        printf, lun,"[CENTROID] Input must be a 2-D array"

     ;;==Return null value
     return, !NULL
  endelse

end
