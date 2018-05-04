;+
; Routine for producing plot frames or movies from EPPIC data.
;
; This routine steps through a (1+1)-D array, captures a plot frame at
; each step, then either writes that frame to an open video stream or
; saves it to a file.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; ARG1 (optional)
;    1-D array of x-axis points.
; ARG2 (required)
;    (1+1)-D array from which to make plot frames.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; LOG (default: unset)
;    Take the logarithm of each frame before creating a plot.
;    The value of alog_base sets the logarithmic base.
; ALOG_BASE (default: 10)
;    String or number indicating the logarithmic base to use when 
;    /log is true. The use can pass the following values:
;    10 or '10' for base-10 (alog10); 2 or '2' for base-2 (alog2);
;    any string starting with 'e', any string whose first 3 letters
;    are 'nat', or the value exp(1) for base-e (alog). Setting this
;    parameter will set log = 1B
; FILENAME (default: 'data_movie.mp4' or 'data_frame.pdf')
;    Name of resultant graphics file, including extension. 
;    IDL will use the extension to determine the file type. 
;    For videos, the user can call 
;    IDL> idlffvideowrite.getformats()
;    or
;    IDL> idlffvideowrite.getformats(/long_names)
;    for more information on available formats. See also the 
;    IDL help page for idlffvideowrite.
; FRAMERATE (default: 20)
;    Movie frame rate.
; RESIZE (default: [1.0, 1.0])
;    Normalized factor by which to resize the graphics window.
;    This parameter can be a scalar, in which case this routine
;    will apply the same value to both axes, or it can be a vector
;    with one value for each axis. 
; PLOT_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's plot.pro.
;    Unlike plot.pro, the 'title' parameter may consist of one
;    element for each time step. In that case, this routine will
;    iterate through 'title', passing one value to the plot()
;    call for each frame. See also the IDL help page for plot.pro.
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
; LEGEND_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's legend.pro,
;    with the exception that this routine will automatically set 
;    target = plt. See also the IDL help page for legend.pro.
; TEXT_XYZ (default: [0.0, 0.0, 0.0])
;    Array containing the x, y, and z positions for text.pro.
;    See also the IDL help page for text.pro.
; TEXT_STRING (default: none)
;    The string or string array to print with text.pro. The 
;    presence or absence of this string determines whether or 
;    not this routine calls text(). This routine currently only
;    supports a single string, which it will use at each time 
;    step, or an array of strings with length equal to the number
;    of time steps. See also the IDL help page for text.pro.
; TEXT_FORMAT (default: 'k')
;    String that sets the text color using short tokens. See
;    also the IDL help page for text.pro.
; TEXT_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's text.pro. 
;    See also the IDL help page for text.pro.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This routine assumes the final dimension of pltdata 
;    is the time-step dimension. 
; -- This routine makes local copies of plot_kw, legend_kw, and
;    text_kw so it can make local changes to dictionary members
;    while preserving the input dictionaries between subsequent
;    calls.
; -- This routine automatically sets the buffer keyword 
;    to 1B to ensure that the current frame goes to a 
;    buffer instead of printing to the screen. The latter 
;    would slow the process considerably and clutter the 
;    screen. 
; -- This routine requires that the frame dimensions match 
;    the dimensions of the initialized video stream. If the 
;    user does not pass in the dimensions keyword, this routine 
;    sets it to [nx,ny], where nx and ny are derived from the 
;    input data arrays.
;-
pro plot_graphics, arg1,arg2, $
                   lun=lun, $
                   log=log, $
                   alog_base=alog_base, $
                   filename=filename, $
                   framerate=framerate, $
                   resize=resize, $
                   plot_kw=plot_kw, $
                   add_legend=add_legend, $
                   legend_kw=legend_kw, $
                   text_xyz=text_xyz, $
                   text_string=text_string, $
                   text_format=text_format, $
                   text_kw=text_kw, $
                   make_movie=make_movie, $
                   make_frame=make_frame

  ;;==Copy input quantities that may change
  if keyword_set(plot_kw) then p_kw = plot_kw[*]
  if keyword_set(legend_kw) then l_kw = legend_kw[*]
  if keyword_set(text_kw) then t_kw = text_kw[*]
  if keyword_set(text_string) then t_string = text_string

  ;;==Check for x-axis data
  if n_elements(arg2) eq 0 then begin
     pltdata = arg1
     msize = size(pltdata)
     xdata = lindgen(msize[1])
  endif $
  else begin
     xdata = arg1
     pltdata = arg2
  endelse

  ;;==Make sure target directory exists for movies
  if keyword_set(make_movie) then begin
     if ~file_test(file_dirname(filename),/directory) then $
        spawn, 'mkdir -p '+file_dirname(filename)
  endif

  ;;==Get data size
  xsize = size(xdata)
  nx = xsize[1]
  ysize = size(pltdata)
  ny = ysize[1]
  nt = ysize[2]

  ;;==Defaults and guards
  if n_elements(filename) eq 0 then begin
     if keyword_set(make_movie) then filename = 'data_movie.mp4'
     if keyword_set(make_frame) then filename = 'data_frame.pdf'
  endif
  if keyword_set(make_frame) && $
     ~p_kw.haskey('overplot') && $
     n_elements(filename) eq 1 && nt gt 1 then $
        filename = strip_extension(filename)+ $
                   '-'+strcompress(sindgen(nt),/remove_all)+ $
                   '.'+get_extension(filename)
  if n_elements(framerate) eq 0 then framerate = 20
  if n_elements(xdata) eq 0 then xdata = indgen(nx)
  if n_elements(resize) eq 0 then resize = [1.0, 1.0]
  if n_elements(resize) eq 1 then resize = [resize, resize]
  if n_elements(p_kw) eq 0 then begin
     if n_elements(ex) ne 0 then p_kw = ex $
     else p_kw = dictionary()
  endif
  if isa(p_kw,'struct') then p_kw = dictionary(p_kw,/extract)
  if keyword_set(make_movie) then begin
     if ~p_kw.haskey('dimensions') then $
        p_kw['dimensions'] = [nx,ny]
     tmp = [p_kw.dimensions[0]*resize[0], $
            p_kw.dimensions[1]*resize[1]]
     p_kw.dimensions = tmp
  endif
  if p_kw.haskey('title') then begin
     case n_elements(p_kw.title) of
        0: title = make_array(nt,value='')
        1: title = make_array(nt,value=p_kw.title)
        nt: title = p_kw.title
        else: title = !NULL
     endcase
     p_kw.remove, 'title'
  endif
  if p_kw.haskey('color') then begin
     case n_elements(p_kw.color) of
        0: color = make_array(nt,value='black')
        1: color = make_array(nt,value=p_kw.color)
        nt: color = p_kw.color
        else: color = !NULL
     endcase
     p_kw.remove, 'color'
  endif
  if p_kw.haskey('overplot') then begin
     case n_elements(p_kw.overplot) of
        0: overplot = make_array(nt,value=0)
        1: overplot = make_array(nt,value=p_kw.overplot)
        nt: overplot = p_kw.overplot
        else: overplot = !NULL
     endcase
     p_kw.remove, 'overplot'
  endif
  if n_elements(t_string) eq 1 then $
     t_string = make_array(nt,value=t_string)

  ;;==Open video stream
  if keyword_set(make_movie) then begin
     printf, lun,"[PLOT_GRAPHICS] Creating ",filename,"..."
     video = idlffvideowrite(filename)
     stream = video.addvideostream(p_kw.dimensions[0], $
                                   p_kw.dimensions[1], $
                                   framerate)
  endif

  ;;==Write data to video stream at each time step
  for it=0,nt-1 do begin
     ydata = pltdata[*,it]
     if n_elements(title) ne 0 then $
        p_kw['title'] = title[it]
     if n_elements(color) ne 0 then $
        p_kw['color'] = color[it]
     if n_elements(overplot) ne 0 then $
        p_kw['overplot'] = overplot[it]
     if n_elements(t_string) ne 0 then $
        tmp_str = t_string[it]
     plt = plot_frame(xdata,ydata, $
                      plot_kw=p_kw, $
                      legend_kw=l_kw, $
                      add_legend=add_legend, $
                      text_xyz=text_xyz, $
                      text_string=tmp_str, $
                      text_format=text_format, $
                      text_kw=t_kw)
     if keyword_set(make_movie) then begin
        frame = plt.copywindow()
        !NULL = video.put(stream,frame)
        plt.close
     endif
     if keyword_set(make_frame) then begin
        if ~keyword_set(multi_page) && ~p_kw.haskey('overplot') then $
           frame_save, plt, $
                       filename = filename[it], $
                       lun = lun
     endif
  endfor
  if keyword_set(make_frame) then begin
     if keyword_set(multi_page) then $
        frame_save, plt, $
                    filename = filename, $
                    lun = lun
     if p_kw.haskey('overplot') then $
        frame_save, plt, $
                    filename = filename, $
                    lun = lun
  endif

  ;;==Close video stream
  if keyword_set(make_movie) then $
     video.cleanup
  printf, lun,"[PLOT_GRAPHICS] Finished"

end
