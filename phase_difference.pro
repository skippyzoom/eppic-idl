;+
; Calculate the estimated phase difference between two functions,
; using their auto correlation functions (ACFs) and cross correlation
; function (CCF).
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; F1,F2 (required)
;    The functions from which to calculate a phase difference.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; QUIET (default: unset)
;    Do not print warning messages
; <return>
;    The floating point phase difference, if the function succeeded,
;    or !NULL if it didn't. Since !NULL has zero elements, the
;    user can check the number of elements of the return value before
;    proceeding. 
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This method only formally applies when the input functions are
;    purely sinusoidal.
;-
function phase_difference, f1,f2, $
                           lun=lun, $
                           quiet=quiet

  ;;==Set the default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Check for correct number of dimensions
  if size(f1,/n_dim) eq 2 && size(f2,/n_dim) eq 2 then begin

     ;;==Get array dimensions
     fsize = size(f1)
     nx = fsize[1]
     ny = fsize[2]

     ;;==Calculate ACFs and CCF
     f12_cc = convol_fft(f1,f2,/correlate)
     f1_acf = convol_fft(f1,f1,/auto_correlation)
     f2_acf = convol_fft(f2,f2,/auto_correlation)

     ;;==Extract values at zero lag
     r12 = f12_cc[nx/2-1,ny/2-1]
     r1 = f1_acf[nx/2-1,ny/2-1]
     r2 = f2_acf[nx/2-1,ny/2-1]

     ;;==Compute the phase difference
     phi = acos(r12/sqrt(r1*r2))

     ;;==Return the computed phase difference
     return, phi
  endif $
  else begin

     ;;==Let the user know of incorrect number of dimensions
     if ~keyword_set(quiet) then $
        printf, lun,"[PHASE_DIFFERENCE] Both input arrays must be 2-D"

     ;;==Return null value
     return, !NULL
  endelse

end
