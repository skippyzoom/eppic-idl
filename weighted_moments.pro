;+
; Calculate the weighted moments of a distribution.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; VALUES (required)
;    Distribution whose weighted moments to calculate.
; WEIGHTS (required)
;    Array of weights, one for each value.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; STANDARD_DEVIATION (default: unset)
;    If set, return the second moment as standard deviation rather
;    than as variance.
; <return>
;    Five-member array of weighted moments, in increasing order.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This is the LEAST EFFICIENT way to do it but it's a
;    start. It also makes it easier to debug. There should be a way to
;    do this in one pass via the binomial theorem. See
;    eppic/src/moment.cc
;-
function weighted_moments, values,weights, $
                           lun=lun, $
                           standard_deviation=standard_deviation

  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Check size of values and weights
  if n_elements(values) ne n_elements(weights) then begin
     printf, lun, "Must have same number of values and weights."
     return, !NULL
  endif $
  else begin
     ;;==Get the number of elements
     nw = n_elements(weights) 

     ;;==Set up the array of weighted moments
     wm = fltarr(5)*0.0

     ;;==Calculate the sum (zeroth moment)
     for i=0,nw-1 do begin
        w = weights[i]
        wm[0] += w
     endfor

     ;;==Calculate the mean (first moment)
     for i=0,nw-1 do begin
        w = weights[i]
        x = values[i]
        wm[1] += w*x
     endfor
     wm[1] /= wm[0]

     ;;==Calculate the variance (second moment)
     for i=0,nw-1 do begin
        w = weights[i]
        x = values[i]
        wm[2] += w*(x-wm[1])^2
     endfor
     wm[2] /= wm[0]
     ;;==Convert to standard deviation, if requested
     if keyword_set(standard_deviation) then wm[2] = sqrt(wm[2])

     ;;==Calculate the skewness (third moment)
     for i=0,nw-1 do begin
        w = weights[i]
        x = values[i]
        wm[3] += w*(x-wm[1])^3
     endfor
     wm[3] /= wm[0]*sqrt(wm[2])^3

     ;;==Calculate the kurtosis (fourth moment)
     for i=0,nw-1 do begin
        w = weights[i]
        x = values[i]
        wm[4] += w*(x-wm[1])^4
     endfor
     wm[4] /= wm[0]*sqrt(wm[2])^4

     ;;==Return array of moments
     return, wm

  end
