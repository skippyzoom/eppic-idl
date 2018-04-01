;+
; Routine for producing movies of image frames of data.
;
; This routine steps through a (2+1)-D array, captures an 
; image frame at each time step, then writes that frame to 
; a video stream.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; MOVDATA (required)
;    A (2+1)-D array from which to make image frames.
; XDATA (optional)
; YDATA (optional)
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
; -- This routine assumes the final dimension of movdata 
;    is the time-step dimension. 
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
pro image_graphics, movdata,xdata,ydata, $
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
                    make_movie=make_movie, $
                    make_frame=make_frame, $
                    _EXTRA=ex

  ;;==Get data size
  data_size = size(movdata)
  n_dims = data_size[0]
  nt = data_size[n_dims]
  nx = data_size[1]
  ny = data_size[2]

  ;;==Defaults and guards
  if ~keyword_set(log) && n_elements(alog_base) ne 0 then $
     log = 1B
  if n_elements(alog_base) eq 0 then alog_base = '10'
  if n_elements(filename) eq 0 then begin
     if keyword_set(make_movie) then filename = 'data_movie.mp4'
     if keyword_set(make_image) then filename = 'data_image.pdf'
  endif
  if keyword_set(make_frame) && n_elements(filename) eq 1 then $
     filename = make_array(nt,value=filename)
  if n_elements(framerate) eq 0 then framerate = 20
  if n_elements(xdata) eq 0 then xdata = indgen(nx)
  if n_elements(ydata) eq 0 then ydata = indgen(ny)
  if n_elements(resize) eq 0 then resize = [1.0, 1.0]
  if n_elements(resize) eq 1 then resize = [resize, resize]
  if n_elements(image_kw) eq 0 then begin
     if n_elements(ex) ne 0 then image_kw = ex $
     else image_kw = dictionary()
  endif
  if isa(image_kw,'struct') then image_kw = dictionary(image_kw,/extract)
  if ~image_kw.haskey('dimensions') then $
     image_kw['dimensions'] = [nx,ny]
  tmp = [image_kw.dimensions[0]*resize[0], $
         image_kw.dimensions[1]*resize[1]]
  image_kw.dimensions = tmp
  if image_kw.haskey('title') then begin
     case n_elements(image_kw.title) of
        0: title = make_array(nt,value='')
        1: title = make_array(nt,value=image_kw.title)
        nt: title = image_kw.title
        else: title = !NULL
     endcase
     image_kw.remove, 'title'
  endif
  if keyword_set(add_colorbar) then begin
     if isa(add_colorbar,/number) && $
        add_colorbar eq 1 then orientation = 0 $
     else if strcmp(add_colorbar,'h',1) then orientation = 0 $
     else if strcmp(add_colorbar,'v',1) then orientation = 1 $
     else begin 
        printf, lun,"[IMAGE_GRAPHICS] Did not recognize value of add_colorbar"
        add_colorbar = 0B
     endelse
  endif
  if n_elements(text_pos) eq 0 then text_pos = [0.0, 0.0, 0.0] $
  else if n_elements(text_pos) eq 2 then $
     text_pos = [text_pos[0], text_pos[1], 0.0]
  case n_elements(text_string) of
     0: make_text = 0B
     1: begin
        text_string = make_array(nt,value=text_string)
        make_text = 1B
     end
     nt: make_text = 1B
     else: begin
        printf, lun,"[IMAGE_GRAPHICS] Cannot use text_string for text."
        printf, lun,"                 Please provide a single string"
        printf, lun,"                 or an array with one element per"
        printf, lun,"                 time step."
        make_text = 0B
     end
  endcase
  if n_elements(text_format) eq 0 then text_format = 'k'
  if n_elements(text_kw) eq 0 then text_kw = dictionary()

  ;;==Open video stream
  if keyword_set(make_movie) then begin
     printf, lun,"[IMAGE_GRAPHICS] Creating ",filename,"..."
     video = idlffvideowrite(filename)
     stream = video.addvideostream(image_kw.dimensions[0], $
                                   image_kw.dimensions[1], $
                                   framerate)
  endif

  ;;==Write data to video stream at each time step
  for it=0,nt-1 do begin
     fdata = movdata[*,*,it]
     img = image_frame(fdata,xdata,ydata, $
                       title=title, $
                       image_kw=image_kw, $
                       colorbar_kw=colobar_kw, $
                       add_colorbar=add_colorbar, $
                       text_kw=text_kw)
     if keyword_set(make_movie) then begin
        frame = img.copywindow()
        !NULL = video.put(stream,frame)
        img.close
     endif
     if keyword_set(make_frame) then begin
        if ~keyword_set(multi_page) then $
           image_save, img, $
                       filename = filename[it], $
                       lun = lun
     endif
  endfor
  if keyword_set(make_frame) then begin
     if keyword_set(multi_page) then $
        image_save, img, $
                    filename = filename, $
                    lun = lun
  endif

  ;;==Close video stream
  if keyword_set(make_movie) then $
     video.cleanup
  printf, lun,"[IMAGE_GRAPHICS] Finished"

end
