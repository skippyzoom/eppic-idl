;+
; Overlay specified radial and axial markers onto an image
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; IMG (required)
;    Handle of image on which to draw.
; R (required)
;    Array of radii at which to draw circles.
; THETA (required)
;    Array of angles at which to draw lines.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; DEGREES (default: unset)
;    Boolean indicating that THETA is in degrees.
; RADIANS (default: unset)
;    Dummy boolean. This keyword exists to allow the function to
;    proceed if the user sets '/radians' in place of '/degrees'. 
; R_COLOR (default: 'black')
;    String color of circles. See man page for IDL's ellipse().
; R_THICK (default: 1)
;    Integer thickness of circles.  See man page for IDL's ellipse().
; R_LINESTYLE (default: 'solid_line')
;    String line style of circles.  See man page for IDL's ellipse().
; THETA_COLOR (default: 'black')
;    String color of lines. See man page for IDL's polyline().
; THETA_THICK (default: 1)
;    Integer thickness of lines.  See man page for IDL's polyline().
; THETA_LINESTYLE (default: 'solid_line')
;    String line style of lines.  See man page for IDL's polyline().
; <return>
;    The updated image handle.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- You can use R to control the length of the radial spokes to be
;    drawn at the angle(s) given by THETA without drawing circles at
;    the radii given by R by setting r_linestyle = 'none'
;-
function overlay_rtheta, img,r,theta, $                         
                         lun=lun, $
                         degrees=degrees, $
                         radians=radians, $
                         center=center, $
                         r_color=r_color, $
                         r_thick=r_thick, $
                         r_linestyle=r_linestyle, $
                         theta_color=theta_color, $
                         theta_thick=theta_thick, $
                         theta_linestyle=theta_linestyle

  ;;==Preserve input arrays
  r_in = r
  theta_in = theta

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(center) eq 0 then center = [0.0,0.0]
  if n_elements(r_color) eq 0 then r_color = 'black'
  if n_elements(r_thick) eq 0 then r_thick = 1
  if n_elements(r_linestyle) eq 0 then r_linestyle = 'solid_line'
  if n_elements(theta_color) eq 0 then theta_color = 'black'
  if n_elements(theta_thick) eq 0 then theta_thick = 1
  if n_elements(theta_linestyle) eq 0 then theta_linestyle = 'solid_line'

  ;;==Determine number of radii
  nr = n_elements(r)

  ;;==Draw a circle at each radius
  for ir=0,nr-1 do $
     ell = ellipse(center[0],center[1], $
                   major = r[ir], $
                   target = img, $
                   /data, $
                   color = r_color, $
                   thick = r_thick, $
                   linestyle = r_linestyle, $
                   fill_background = 0)

  ;;==Determine number of angles
  nth = n_elements(theta)

  ;;==Get the largest radius
  max_r = max(r)

  ;;==Convert angles from degrees to radians, if necessary
  if keyword_set(degrees) then theta *= !dtor

  ;;==Draw a line at each angle
  for ith=0,nth-1 do $
     lin = polyline([center[0],center[0]+max_r*cos(theta[ith])], $
                    [center[1],center[1]+max_r*sin(theta[ith])], $
                    target = img, $
                    /data, $
                    color = theta_color, $
                    linestyle = theta_linestyle, $
                    thick = theta_thick)

  ;;==Restore original input arrays
  r = r_in
  theta = theta_in

  ;;==Return the image handle
  return, img
end
