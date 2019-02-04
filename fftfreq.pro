;+
; Return the sample frequencies for a given number of FFT points
;
; Created by Matt Young
; This function is based on a code snipet shown on the idl fft.pro
; help page.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; N (required)
;    The number of FFT points.
; D (default: 1.0)
;    The sampling interval.
; <return> (float array)
;    The sample frequencies.
;-
function fftfreq, n,d

  ;;==Set default sampling interval
  if n_elements(d) eq 0 then d = 1.0

  ;;==Declare array of points up to Nyquist
  x = findgen((n-1)/2) + 1

  ;;==Calculate frequencies
  n_is_even = (n mod 2) eq 0
  if n_is_even then $
     freq = [0.0, x, n/2, -n/2 + x]/(n*d) $
  else $
     freq = [0.0, x, -(n/2 + 1) + x]/(n*d)

  ;;==Return
  return, freq

end
