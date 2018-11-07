;+
; Calculate and return the distance from the center of an area to its
; edge (e.g., an image frame), given the linear dimensions and an
; angle from zero.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; XLEN (required)
;    Length of the target area in the x dimension
; YLEN (required)
;    Length of the target area in the y dimension
; ANGLE (required)
;    Angle from 0.0 along which to calculate distance
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; QUIET (default: unset)
;    Suppress runtime messages
; <return> (float)
;    Distance from center to edge along the direction given by ANGLE
;-
function r_to_edge, xlen,ylen,angle, $
                    lun=lun, $
                    quiet=quiet

  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Preserve input values
  angle_in = angle

  ;;==Rotate out-of-range angles
  if angle lt -0.25*!pi then angle = 2*!pi+(angle mod (2*!pi))
  if angle gt +1.75*!pi then angle = (angle mod (2*!pi))-2*!pi

  ;;==Fix the special boundary case
  if angle eq +1.75*!pi then angle = -0.25*!pi

  ;;==Calculate distance to frame edge based on angle
  case 1B of
     (angle ge -0.25*!pi) && (angle lt +0.25*!pi): $
        r = abs(0.5*xlen)/sqrt(1-sin(angle)^2)
     (angle ge +0.25*!pi) && (angle lt +0.75*!pi): $
        r = abs(0.5*ylen)/sqrt(1-cos(angle)^2)
     (angle ge +0.75*!pi) && (angle lt +1.25*!pi): $
        r = abs(0.5*xlen)/sqrt(1-sin(angle)^2)
     (angle ge +1.25*!pi) && (angle lt +1.75*!pi): $
        r = abs(0.5*ylen)/sqrt(1-cos(angle)^2)
     else: begin
        if ~keyword_set(quiet) then $
           printf, lun,"[R_TO_EDGE] Could not determine angle. Make sure "+ $
                   "the input value is in radians."
        r = 0.0
     end
  endcase

  ;;==Reset input values
  angle = angle_in

  return, r
end
