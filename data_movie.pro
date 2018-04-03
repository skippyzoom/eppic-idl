;+
; Routine for producing movies of EPPIC data from a (2+1)-D array.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; ARG1 (required)
;    Either a (2+1)-D array from which to make images,
;    a (1+1)-D array from which to make plots, or a 1-D
;    array of x-axis points for making plots.
; ARG2 (optional)
;    Either a 1-D array of x-axis points for making images
;    or a (1+1)-D array from which to make plots when arg1
;    is a 1-D array of x-axis points.
; ARG3 (optional)
;    1-D array of y-axis points for making images.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
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
; FILENAME (default: 'data_movie.mp4')
;    Name of resultant movie file, including extension. IDL will 
;    use the extension to determine the video type. The user can
;    call 
;    IDL> idlffvideowrite.getformats()
;    or
;    IDL> idlffvideowrite.getformats(/long_names)
;    for more information on available video formats. See also the 
;    IDL help page for idlffvideowrite.
; FRAMERATE (default: 20)
;    Movie frame rate.
; RESIZE (default: [1.0, 1.0])
;    Normalized factor by which to resize the graphics window.
;    This parameter can be a scalar, in which case this routine
;    will apply the same value to both axes, or it can be a vector
;    with one value for each axis. 
; IMAGE_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's image.pro.
;    Unlike image.pro, the 'title' parameter may consist of one
;    element for each time step. In that case, this routine will
;    iterate through 'title', passing one value to the image()
;    call for each frame. See also the IDL help page for image.pro.
; PLOT_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's plot.pro.
;    Unlike plot.pro, the 'title' parameter may consist of one
;    element for each time step. In that case, this routine will
;    iterate through 'title', passing one value to the plot()
;    call for each frame. See also the IDL help page for plot.pro.
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
; ADD_LEGEND (default: unset)
;    Toggle a legend with minimal keyword properties. This keyword
;    allows the user to have a reference before passing more keyword
;    properties via legend_kw. If the user sets this keyword as a
;    boolean value (typically, /add_legend) then this routine will 
;    create a vertical legend. The user may also set this keyword
;    to 'horizontal' or 'vertical', including abbreviations (e.g., 'h'
;    or 'vert'), to create a legend with the corresponding orientation.
;    This routine will ignore this keyword if the user passes a 
;    dictionary for legend_kw.
; COLORBAR_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's colorbar.pro,
;    with the exception that this routine will automatically set 
;    target = img. See also the IDL help page for colorbar.pro.
; LEGEND_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's legend.pro,
;    with the exception that this routine will automatically set 
;    target = plt. See also the IDL help page for legend.pro.
; TEXT_POS (default: [0.0, 0.0, 0.0])
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
; TEXT_KW (default: none)
;   Dictionary of keyword properties accepted by IDL's text.pro. 
;   See also the IDL help page for text.pro.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This routine selects movie_frame_plot or movie_frame_image,
;    and the appropriate calling sequence, based on the dimensions 
;    of arg1, arg2, and arg3.
;-
pro data_movie, arg1,arg2,arg3, $
                lun=lun, $
                log=log, $
                alog_base=alog_base, $
                filename=filename, $
                framerate=framerate, $
                resize=resize, $
                image_kw=image_kw, $
                plot_kw=plot_kw, $
                add_colorbar=add_colorbar, $
                add_legend=add_legend, $
                colorbar_kw=colorbar_kw, $
                legend_kw=legend_kw, $
                text_pos=text_pos, $
                text_string=text_string, $
                text_format=text_format, $
                text_kw=text_kw, $
                _EXTRA=ex

  ;;==Default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Determine image/plot mode from input dimensions
  size1 = size(arg1)
  call_seq_err = 0B
  case size1[0] of
     1: begin
        size2 = size(arg2)
        if size2[0] eq 2 then begin

           ;;==Make movie from plot frames
           plot_graphics, arg1,arg2, $
                          lun=lun, $
                          log=log, $
                          alog_base=alog_base, $
                          filename=filename, $
                          framerate=framerate, $
                          resize=resize, $
                          plot_kw=plot_kw, $
                          add_legend=add_legend, $
                          legend_kw=legend_kw, $
                          text_pos=text_pos, $
                          text_string=text_string, $
                          text_format=text_format, $
                          text_kw=text_kw, $
                          /make_movie, $
                          _EXTRA=ex

        endif $
        else call_seq_err = 1B
     end
     2: begin

        ;;==Make movie from plot frames
        plot_graphics, arg1, $
                       lun=lun, $
                       log=log, $
                       alog_base=alog_base, $
                       filename=filename, $
                       framerate=framerate, $
                       resize=resize, $
                       plot_kw=plot_kw, $
                       add_legend=add_legend, $
                       legend_kw=legend_kw, $
                       text_pos=text_pos, $
                       text_string=text_string, $
                       text_format=text_format, $
                       text_kw=text_kw, $
                       /make_movie, $
                       _EXTRA=ex

     end
     3: begin
        size2 = size(arg2)
        size3 = size(arg3)
        case 1B of
           (size2[0] eq 1 and size3[0] eq 1): begin

              ;;==Make movie from image frames
              image_graphics, arg1,arg2,arg3, $
                              lun=lun, $
                              log=log, $
                              alog_base=alog_base, $
                              filename=filename, $
                              framerate=framerate, $
                              resize=resize, $
                              image_kw=image_kw, $
                              add_colorbar=add_colorbar, $
                              colorbar_kw=colorbar_kw, $
                              text_pos=text_pos, $
                              text_string=text_string, $
                              text_format=text_format, $
                              text_kw=text_kw, $
                              /make_movie, $
                              _EXTRA=ex

           end
           (size2[0] eq 0 and size3[0] eq 0): begin

              ;;==Make movie from image frames
              movdata = arg1
              image_graphics, movdata, $
                              lun=lun, $
                              log=log, $
                              alog_base=alog_base, $
                              filename=filename, $
                              framerate=framerate, $
                              resize=resize, $
                              image_kw=image_kw, $
                              add_colorbar=add_colorbar, $
                              colorbar_kw=colorbar_kw, $
                              text_pos=text_pos, $
                              text_string=text_string, $
                              text_format=text_format, $
                              text_kw=text_kw, $
                              /make_movie, $
                              _EXTRA=ex

           end
           else: call_seq_err = 1B
        endcase
     end
     else: call_seq_err = 1B
  endcase
  if call_seq_err then begin
     printf, lun,"[DATA_MOVIE] Calling sequence may be either"
     printf, lun,"             > data_movie, xdata[,ydata][,kw/prop]"
     printf, lun,"             with 1-D xdata and (1+1)-D ydata"
     printf, lun,"             for a movie of plot frames"
     printf, lun,"                         OR"
     printf, lun,"             > data_movie, fdata[,xdata][,ydata][,kw/prop]"
     printf, lun,"             with (2+1)-D fdata, 1-D xdata, and 1-D ydata"
     printf, lun,"             for a movie of image frames"
  endif

end
