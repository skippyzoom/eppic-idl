;+
; Compute the relative drift velocity of two EPPIC distributions,
; using vector_difference.pro. This function accounts for the fact
; that 3-D EPPIC runs orient B along the x axis.
;
; Created by Matt Young
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; D1 (required)
;    First distribution. May be a struct or a dictionary.
; D2 (required)
;    Second distribution. May be a struct or a dictionary.
; NDIM (default: 2)
;    Number of spatial dimensions of EPPIC run.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; QUIET (default: unset)
;    Do not print runtime messages
; <return> (dictionary)
;    The components returned from vector_difference.pro, if the
;    function succeeded, or !NULL if it didn't. Since !NULL
;    has zero elements, the user can check the number of elements of
;    the return value before proceeding.
; 
function build_drift_velocity, d1,d2,ndim, $
                               lun=lun, $
                               quiet=quiet

  ;;==Set defaults
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(ndim) eq 0 then ndim = 2

  ;;==Set appropriate components and calculate drift velocity
  case ndim of
     2: begin
        vex = +d1.vx_m1
        vix = +d2.vx_m1
        vey = +d1.vy_m1
        viy = +d2.vy_m1
        vez = +d1.vz_m1
        viz = +d2.vz_m1
        vd = vector_difference(vex,vix,vey,viy,vez,viz)
     end
     3: begin
        vex = -d1.vz_m1
        vix = -d2.vz_m1
        vey = +d1.vy_m1
        viy = +d2.vy_m1
        vez = +d1.vx_m1
        viz = +d2.vx_m1
        vd = vector_difference(vex,vix,vey,viy,vez,viz)
     end
     else: begin
        if ~keyword_set(quiet) then begin
           printf, lun,"[BUILD_DRIFT_VELOCITY] Spatial dimensions"
           printf, lun,"                       must be 2D or 3D"
        endif
        vd = !NULL
     end
  endcase

  ;;==Return drift velocity dictionary
  return, vd
end
