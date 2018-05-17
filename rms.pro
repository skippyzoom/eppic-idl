;+
; Compute the RMS of input data.
; 
; This function computes the root-mean-sqaured value of its input. It
; accepts input and keyword parameters identically to IDL's mean().
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA (required)
;    Array of integers or floats.
; NORMALIZE (default: unset)
;    Normalize the RMS array before returning
; <return>
;    Scalar or array of the same type as DATA, containing the RMS
;    value. Use of the 'dimension' keyword to mean() determines the
;    dimensions of the result.
;-
function rms, data, $
              normalize=normalize, $
              _EXTRA=ex

  ;;==Calculate RMS
  data_rms = sqrt(mean(data^2,_EXTRA=ex))

  ;;==Normalize, if requested
  if keyword_set(normalize) then $
     data_rms /= max(data_rms)

  return, data_rms
end
