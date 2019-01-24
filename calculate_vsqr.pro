;+
; This function calculates the squared velocity, as a function of
; space, of an EPPIC distribution. Typically, the user will use the
; return value to compute temperature as a function of space. 
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DEN (required)
;    The density array. May be (2+1)-D or (3+1)-D
; V0 (required)
;    The mean velocity. May be a scalar, 1-D array, or array with
;    dimensions equal to den.
; NVSQR (required)
;    The nv^2 array. May be (2+1)-D or (3+1)-D
; LUN (default: -1)
;    Logical unit number for printing runtime messages
; <return> (array of same type as DEN)
;    Mean squared velocity of the distribution. The returned array
;    will have the same shape as den.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This function uses EPPIC den (zeroth moment) and nvsqr (second
;    moment) output quantities. It accepts a few options for v0 (first
;    moment, a.k.a mean velocity).

function calculate_vsqr, den, $
                         v0, $
                         nvsqr, $
                         lun=lun
  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get time steps from den
  dsize = size(den)
  nt = dsize[dsize[0]]

  ;;==Reform den for 3D, if necessary
  if size(den,/n_dim) eq 3 then den = reform(den, $
                                             [dsize[1],dsize[2],1,nt])

  ;;==Reform v0 for 3D, if necessary
  if size(v0,/n_dim) eq 3 then v0 = reform(v0, $
                                           [dsize[1],dsize[2],1,nt])
  ;;==Reform nvsqr for 3D, if necessary
  if size(nvsqr,/n_dim) eq 3 then nvsqr = reform(nvsqr, $
                                                 [dsize[1],dsize[2],1,nt])

  ;;==Set up vsqr
  vsqr = den*0.0
  vdims = size(v0,/n_dim)

  ;;==Calculate vsqr
  case vdims of
     0: begin
        ;; vsqr = (sqrt(nvsqr/den) - v0)^2
        vsqr = nvsqr/den - v0^2
     end
     1: begin
        ;; for it=0,nt-1 do $
        ;;    vsqr[*,*,*,it] = (sqrt(nvsqr[*,*,*,it]/den[*,*,*,it]) - v0[it])^2
        for it=0,nt-1 do $
           vsqr[*,*,*,it] = nvsqr[*,*,*,it]/den[*,*,*,it] - v0[it]^2
     end
     size(den,/n_dim): begin
        ;; vsqr = (sqrt(nvsqr/den) - v0)^2
        vsqr = nvsqr/den - v0^2
     end
     else: begin
        printf, lun,"[CALCULATE_VSQR] Dimensions of v0 are incompatible"
        printf, lun,"                 with those of den."
     end
  endcase

  ;;==Return vsqr
  return, vsqr
end
