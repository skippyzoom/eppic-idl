;+
; Function for producing a single image frame.
;
; This function extracts time-dependent keywords (e.g., title)
; and performs optional data conditioning before creating an 
; image handle to which it may optionally attach a colorbar and
; text. It returns the image handle for use by a calling graphics
; routine
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FDATA (required)
;    2-D array from which to make images.
; XDATA (optional)
;    1-D array of x-axis points.
; YDATA (optional)
;    1-D array of y-axis points.
; LOG (default: unset)
;    Take the logarithm of each frame before creating an image.
;    The value of alog_base sets the logarithmic base.
; ALOG_BASE (default: 10)
;    String or number indicating the logarithmic base to use when 
;    /log is true. The use can pass the following values:
;    10 or '10' for base-10 (alog10); 2 or '2' for base-2 (alog2);
;    any string starting with 'e', any string whose first 3 letters
;    are 'nat', or the value exp(1) for base-e (alog). Setting this
;    parameter will set log = 1B
; IMAGE_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's image.pro.
;    See also the IDL help page for image.pro.
; COLORBAR_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's colorbar.pro,
;    with the exception that this routine will automatically set 
;    target = img. See also the IDL help page for colorbar.pro.
; ADD_COLORBAR (default: unset)
;    Toggle a colorbar with minimal keyword properties. This keyword
;    allows the user to have a reference before passing more keyword
;    properties via colorbar_kw. If the user sets this keyword as a
;    boolean value (typically, /add_colorbar) then this routine will 
;    create a horizontal colorbar. The user may also set this keyword
;    to 'horizontal' or 'vertical', including abbreviations (e.g., 'h'
;    or 'vert'), to create a colorbar with the corresponding orientation.
;    This routine will ignore this keyword if the user passes a 
;    dictionary for colorbar_kw.
; TEXT_XYZ (default: [0.0, 0.0, 0.0])
;    An array containing the x, y, and z positions for text.pro.
;    See also the IDL help page for text.pro.
; TEXT_STRING (default: none)
;    The string or string array to print with text.pro. The 
;    presence or absence of this string determines whether or 
;    not this routine calls text(). This routine currently only
;    supports a single string, which it will use at each time 
;    step, or an array of strings with length equal to the number
;    of time steps. See also the IDL help page for text.pro.
; TEXT_FORMAT (default: 'k')
;    A string that sets the text color using short tokens. See
;    also the IDL help page for text.pro.
; TEXT_KW
;    Dictionary of keyword properties accepted by IDL's text.pro. 
;    See also the IDL help page for text.pro.
; <return>
;    Image handle created by image.pro
;-
function image_frame, fdata,xdata,ydata, $
                      log=log, $
                      alog_base=alog_base, $
                      image_kw=image_kw, $
                      colorbar_kw=colorbar_kw, $
                      add_colorbar=add_colorbar, $
                      text_xyz=text_xyz, $
                      text_string=text_string, $
                      text_format=text_format, $
                      text_kw=text_kw

  ;;==Defaults and guards
  if keyword_set(log) then begin
     if strcmp(alog_base,'10') then alog_base = 10
     if strcmp(alog_base,'2') then alog_base = 2
     if strcmp(alog_base,'e',1) || $
        strcmp(alog_base,'nat',3) then alog_base = exp(1)
     case alog_base of
        10: fdata = alog10(fdata)
        2: fdata = alog2(fdata)
        exp(1): fdata = alog(fdata)
     endcase
  endif
  if keyword_set(add_colorbar) then begin
     if isa(add_colorbar,/number) && $
        add_colorbar eq 1 then orientation = 0 $
     else if strcmp(add_colorbar,'h',1) then orientation = 0 $
     else if strcmp(add_colorbar,'v',1) then orientation = 1 $
     else begin 
        printf, lun,"[IMAGE_FRAME] Did not recognize value of add_colorbar"
        add_colorbar = 0B
     endelse
  endif
  if n_elements(text_xyz) ne 3 then begin
     case n_elements(text_xyz) of 
        0: text_xyz = [0.0, 0.0, 0.0]
        2: text_xyz = [text_xyz[0], text_xyz[1], 0.0]
        else: begin
           cr = (!d.name eq 'WIN') ? string([13B,10B]) : string(10B)
           err_msg = "[IMAGE_FRAME] Inappropriate number of elements "+ $
                     "in text_xyz."+cr+ $
                     "              Using default ([0.0, 0.0, 0.0])"   
           printf, lun,err_msg
        end
     endcase
  endif
  if n_elements(text_format) eq 0 then text_format = 'k'
  if n_elements(text_kw) eq 0 then text_kw = dictionary()

  ;;==Create image object
  img = image(fdata,xdata,ydata, $
              /buffer, $
              _EXTRA=image_kw.tostruct())

  ;;==Attach colorbar, if requested
  if n_elements(colorbar_kw) ne 0 then $
     clr = colorbar(target = img, $
                    _EXTRA = colorbar_kw.tostruct()) $
  else if keyword_set(add_colorbar) then $
     clr = colorbar(target = img, $
                    orientation = orientation)

  ;;==Attach text, if necessary
  if n_elements(text_string) ne 0 then begin
     txt = text(text_xyz[0],text_xyz[1],text_xyz[2], $
                text_string, $
                text_format, $
                target = plt, $
                _EXTRA = text_kw.tostruct())
  endif

  return, img
end
