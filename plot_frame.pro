;+
; Function for producing a single plot frame.
;
; This function extracts time-dependent keywords (e.g., title)
; and performs optional data conditioning before creating a 
; plot handle to which it may optionally attach a legend and
; text. It returns the plot handle for use by a calling graphics
; routine
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; ARG1 (optional)
;    1-D array of x-axis points.
; ARG2 (required)
;    1-D array of y-axis (function) points.
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
; PLOT_KW (default: none)
;    Dictionary of keywords accepted by IDL's plot.pro
;    See also the IDL help page for plot.pro.
; LEGEND_KW
;    Dictionary of keyword properties accepted by IDL's legend.pro,
;    with the exception that this routine will automatically set 
;    target = plt. See also the IDL help page for legend.pro.
; ADD_LEGEND
;    Toggle a legend with minimal keyword properties. This keyword
;    allows the user to have a reference before passing more keyword
;    properties via legend_kw. If the user sets this keyword as a
;    boolean value (typically, /add_legend) then this routine will 
;    create a vertical legend. The user may also set this keyword
;    to 'horizontal' or 'vertical', including abbreviations (e.g., 'h'
;    or 'vert'), to create a legend with the corresponding orientation.
;    This routine will ignore this keyword if the user passes a 
;    dictionary for legend_kw.
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
;    Plot handle created by plot.pro
;-
function plot_frame, arg1,arg2, $
                     log=log, $
                     alog_base=alog_base, $
                     plot_kw=plot_kw, $
                     legend_kw=legend_kw, $
                     add_legend=add_legend, $
                     text_xyz=text_xyz, $
                     text_string=text_string, $
                     text_format=text_format, $
                     text_kw=text_kw

  ;;==Check for x-axis data
  if n_elements(arg2) eq 0 then begin
     ydata = arg1
     ny = n_elements(ydata)
     xdata = lindgen(ny)
  endif $
  else begin
     xdata = arg1
     ydata = arg2
  endelse

  ;;==Defaults and guards
  if keyword_set(log) then begin
     if strcmp(alog_base,'10') then alog_base = 10
     if strcmp(alog_base,'2') then alog_base = 2
     if strcmp(alog_base,'e',1) || $
        strcmp(alog_base,'nat',3) then alog_base = exp(1)
     case alog_base of
        10: ydata = alog10(ydata)
        2: ydata = alog2(ydata)
        exp(1): ydata = alog(ydata)
     endcase
  endif
  if keyword_set(add_legend) then begin
     if isa(add_legend,/number) && $
        add_legend eq 1 then orientation = 0 $
     else if strcmp(add_legend,'h',1) then orientation = 1 $
     else if strcmp(add_legend,'v',1) then orientation = 0 $
     else begin 
        printf, lun,"[PLOT_GRAPHICS] Did not recognize value of add_legend"
        add_legend = 0B
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

  ;;==Create plot handle
  plt = plot(xdata,ydata, $
             /buffer, $
             _EXTRA=plot_kw.tostruct())

  ;;==Attach legend, if requested
  if n_elements(legend_kw) ne 0 then $
     leg = legend(target = plt, $
                  _EXTRA = legend_kw.tostruct()) $
  else if keyword_set(add_legend) then $
     leg = legend(target = plt, $
                  orientation = orientation)

  ;;==Attach text, if requested
  if n_elements(text_string) ne 0 then begin
     txt = text(text_xyz[0],text_xyz[1],text_xyz[2], $
                text_string, $
                text_format, $
                _EXTRA = text_kw.tostruct())
  endif

  ;;==Return the plot handle
  return, plt
end
