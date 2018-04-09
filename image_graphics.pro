;+
; Routine for producing image frames or movies from EPPIC data.
;
; This routine steps through a (2+1)-D array, captures an image frame at
; each step, then either writes that frame to an open video stream or
; saves it to a file.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; IMGDATA (required)
;    A (2+1)-D array from which to make image frames.
; XDATA (optional)
;    A 1-D array of x-axis points.
; YDATA (optional)
;    A 1-D array of y-axis points.
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
; IMAGE_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's image.pro.
;    Unlike image.pro, the 'title' parameter may consist of one
;    element for each time step. In that case, this routine will
;    iterate through 'title', passing one value to the image()
;    call for each frame. See also the IDL help page for image.pro.
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
; COLORBAR_KW (default: none)
;    Dictionary of keyword properties accepted by IDL's colorbar.pro,
;    with the exception that this routine will automatically set 
;    target = img. See also the IDL help page for colorbar.pro.
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
; TEXT_KW (default: none)
;   Dictionary of keyword properties accepted by IDL's text.pro. 
;   See also the IDL help page for text.pro.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This routine assumes the final dimension of imgdata 
;    is the time-step dimension. 
; -- This routine makes local copies of image_kw, colobar_kw, and
;    text_kw so it can make local changes to dictionary members
;    while preserving the input dictionaries between subsequent
;    calls.
; -- This routine automatically sets the buffer keyword 
;    to 1B to ensure that the current frame goes to a 
;    buffer instead of printing to the screen. The latter 
;    would slow the process considerably and clutter the 
;    screen. 
; -- This routine requires that the image dimensions match 
;    the dimensions of the initialized video stream. If the 
;    user does not pass in the dimensions keyword, this routine 
;    sets it to [nx,ny], where nx and ny are derived from the 
;    input data array.
;-
pro image_graphics, imgdata,xdata,ydata, $
                    lun=lun, $
                    log=log, $
                    alog_base=alog_base, $
                    filename=filename, $
                    framerate=framerate, $
                    resize=resize, $
                    image_kw=image_kw, $
                    add_colorbar=add_colorbar, $
                    colorbar_kw=colorbar_kw, $
                    text_xyz=text_xyz, $
                    text_string=text_string, $
                    text_format=text_format, $
                    text_kw=text_kw, $
                    make_movie=make_movie, $
                    make_frame=make_frame

  ;;==Copy input quantities that may change
  if keyword_set(image_kw) then i_kw = image_kw[*]
  if keyword_set(colorbar_kw) then c_kw = colorbar_kw[*]
  if keyword_set(text_kw) then t_kw = text_kw[*]
  if keyword_set(text_string) then t_string = text_string

  ;;==Make sure target directory exists for movies
  if keyword_set(make_movie) then begin
     if ~file_test(file_dirname(filename),/directory) then $
        spawn, 'mkdir -p '+file_dirname(filename)
  endif

  ;;==Get data size
  data_size = size(imgdata)
  n_dims = data_size[0]
  nt = data_size[n_dims]
  nx = data_size[1]
  ny = data_size[2]

  ;;==Defaults and guards
  if n_elements(filename) eq 0 then begin
     if keyword_set(make_movie) then filename = 'data_movie.mp4'
     if keyword_set(make_frame) then filename = 'data_frame.pdf'
  endif
  if keyword_set(make_frame) && n_elements(filename) eq 1 then $
     filename = make_array(nt,value=filename)
  if n_elements(framerate) eq 0 then framerate = 20
  if n_elements(xdata) eq 0 then xdata = indgen(nx)
  if n_elements(ydata) eq 0 then ydata = indgen(ny)
  if n_elements(resize) eq 0 then resize = [1.0, 1.0]
  if n_elements(resize) eq 1 then resize = [resize, resize]
  if n_elements(i_kw) eq 0 then begin
     if n_elements(ex) ne 0 then i_kw = ex $
     else i_kw = dictionary()
  endif
  if isa(i_kw,'struct') then i_kw = dictionary(i_kw,/extract)
  if ~i_kw.haskey('dimensions') then $
     i_kw['dimensions'] = [nx,ny]
  tmp = [i_kw.dimensions[0]*resize[0], $
         i_kw.dimensions[1]*resize[1]]
  i_kw.dimensions = tmp
  if i_kw.haskey('title') then begin
     case n_elements(i_kw.title) of
        0: title = make_array(nt,value='')
        1: title = make_array(nt,value=i_kw.title)
        nt: title = i_kw.title
        else: title = !NULL
     endcase
     i_kw.remove, 'title'
  endif
  if n_elements(text_string) eq 1 then $
     t_string = make_array(nt,value=text_string)

  ;;==Open video stream
  if keyword_set(make_movie) then begin
     printf, lun,"[IMAGE_GRAPHICS] Creating ",filename,"..."
     video = idlffvideowrite(filename)
     stream = video.addvideostream(i_kw.dimensions[0], $
                                   i_kw.dimensions[1], $
                                   framerate)
  endif

  ;;==Write data to video stream at each time step
  for it=0,nt-1 do begin
     fdata = imgdata[*,*,it]
     if n_elements(title) ne 0 then i_kw['title'] = title[it]
     if n_elements(t_string) ne 0 then $
        tmp_str = t_string[it]
     img = image_frame(fdata,xdata,ydata, $
                       image_kw=i_kw, $
                       colorbar_kw=c_kw, $
                       add_colorbar=add_colorbar, $
                       text_xyz=text_xyz, $
                       text_string=tmp_str, $
                       text_format=text_format, $
                       text_kw=t_kw)
     if keyword_set(make_movie) then begin
        frame = img.copywindow()
        !NULL = video.put(stream,frame)
        img.close
     endif
     if keyword_set(make_frame) then begin
        if ~keyword_set(multi_page) then $
           frame_save, img, $
                       filename = filename[it], $
                       lun = lun
     endif
  endfor
  if keyword_set(make_frame) then begin
     if keyword_set(multi_page) then $
        frame_save, img, $
                    filename = filename, $
                    lun = lun
  endif

  ;;==Close video stream
  if keyword_set(make_movie) then $
     video.cleanup
  printf, lun,"[IMAGE_GRAPHICS] Finished"

end
