;+
; Finds the centroid of a 2-D input array.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; IMAGE (required)
;    The 2-D array of which to calculate the centroid.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; MASK_THRESHOLD (default: unset)
;    Floating-point threshold value below which to mask-out data. If
;    the user does not provide a value, the function will skip this
;    operation. 
; MASK_VALUE (default: 0.0)
;    Numerical value to which to set masked elements.
; MASK_TYPE (default: 'absolute')
;    String type of mask threshold. Current options are:
;    'absolute' - Use the user-supplied value of MASK_THRESHOLD
;    'relative_min' - Scale MASK_THRESHOLD to min(image)
;    'relative_max' - Scale MASK_THRESHOLD to max(image)
; QUIET (default: unset)
;    If set, do not print runtime messages.
; <return>
;    Two-element floating-point array containing the centroid of the
;    optionally masked image, if the function succeeded, or
;    !NULL if it didn't.  Since !NULL has zero elements, the 
;    user can check the number of elements of the return value before 
;    proceeding.
;-
function find_image_moments, image, $
                              lun=lun, $
                              mask_threshold=mask_threshold, $
                              mask_value=mask_value, $
                              mask_type=mask_type, $
                              quiet=quiet

  ;;==Set the default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Check for correct number of dimensions
  if size(image,/n_dim) eq 2 then begin

     ;;==Check for user request to mask image
     if keyword_set(mask_threshold) then begin

        ;;==Set default mask value and type
        if n_elements(mask_value) eq 0 then mask_value = 0.0
        if n_elements(mask_type) eq 0 then mask_type = 'absolute'

        ;;==Determine type of mask
        case 1B of
           strcmp(mask_type,'relative_max'): $
              mask_threshold *= max(image)
           strcmp(mask_type,'relative_min'): $
              mask_threshold *= min(image)
           else:                ;Do nothing
        endcase

        ;;==Create mask
        lt_thr = where(image lt mask_threshold)

        ;;==Set mask
        image[lt_thr] = mask_value
     endif

     ;;==Calculate centroid and variance of masked image
     var = fltarr(2)
     rcm = centroid(image,variance=var)

     return, dictionary('centroid',rcm, $
                        'variance',var)
  endif $
  else begin

     ;;==Let the user know of incorrect number of dimensions
     if ~keyword_set(quiet) then $
        prinft, lun,"[FIND_IMAGE_MOMENTS] Input must be 2-D"

     ;;==Return null value
     return, !NULL
  endelse

end
