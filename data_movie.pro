;+
; Routine for producing movies of EPPIC data from a (2+1)-D array.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; MOVDATA (required)
;    A (2+1)-D array from which to make a movie.
; XDATA (optional)
; YDATA (optional)
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; FILENAME (default: 'data_movie.mp4')
;    Name of resultant movie file.
; FRAMERATE (default: 20)
;    Movie frame rate.
; TIMESTAMPS (default: none)
;    Boolean keyword to toggle addition of time stamps to movie.
; RESIZE (default: 1.0)
;    Normalized factor by which to resize the graphics window.
; COLORBAR_TITLE (default: none)
;    String title for colorbar. The presence or absence of this 
;    keyword determines whether or not to draw the colorbar.
; IMAGE_KW (default: none)
;    Dictionary of graphics keywords accepted by IDL's image.pro.
;    Unlike image.pro, the 'title' parameter may consist of one
;    element for each time step. In that case, this routine will
;    iterate through 'title', passing one value to the image()
;    call for each frame.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This routine assumes the final dimension of data 
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
;
;------------------------------------------------------------------------------
;                                   **TO DO**
; -- Improve or remove timestamps option.
;-
pro data_movie, movdata,xdata,ydata, $
                lun=lun, $
                filename=filename, $
                framerate=framerate, $
                timestamps=timestamps, $
                resize=resize, $
                colorbar_title=colorbar_title, $
                image_kw=image_kw, $
                _EXTRA=ex

  ;;==Get data size
  data_size = size(movdata)
  n_dims = data_size[0]

  ;;==Check data size
  if n_dims eq 3 then begin
     nt = data_size[n_dims]
     nx = data_size[1]
     ny = data_size[2]

     ;;==Defaults and guards
     if n_elements(lun) eq 0 then lun = -1
     if n_elements(filename) eq 0 then filename = 'data_movie.mp4'
     if n_elements(framerate) eq 0 then framerate = 20
     if n_elements(xdata) eq 0 then xdata = indgen(nx)
     if n_elements(ydata) eq 0 then ydata = indgen(ny)
     if n_elements(resize) eq 0 then resize = 1.0
     if n_elements(image_kw) eq 0 then begin
        if n_elements(ex) ne 0 then image_kw = ex $
        else image_kw = dictionary()
     endif
     if isa(image_kw,'struct') then image_kw = dictionary(image_kw,/extract)
     if image_kw.haskey('dimensions') then image_kw.dimensions *= resize $
     else image_kw['dimensions'] = [nx,ny]
     if image_kw.haskey('title') then begin
        case n_elements(image_kw.title) of
           0: title = make_array(nt,value='')
           1: title = make_array(nt,value=image_kw.title)
           nt: title = image_kw.title
           else: title = !NULL
        endcase
        image_kw.remove, 'title'
     endif

     ;;==Open video stream
     printf, lun,"[DATA_MOVIE] Creating ",filename,"..."
     video = idlffvideowrite(filename)
     stream = video.addvideostream(image_kw.dimensions[0], $
                                   image_kw.dimensions[1], $
                                   framerate)

     ;;==Write data to video stream
     for it=0,nt-1 do begin
        if n_elements(title) ne 0 then image_kw['title'] = title[it]
        img = image(movdata[*,*,it], $
                    xdata,ydata, $
                    /buffer, $
                    _EXTRA=image_kw.tostruct())
        if keyword_set(colorbar_title) then begin
           pos = img.position
           position = [pos[2]+0.02, $
                       pos[0]+0.15, $
                       pos[2]+0.04, $
                       pos[3]-0.15]
           clr = colorbar(target = img, $
                          title = colorbar_title, $
                          position = position, $
                          orientation = 1, $
                          textpos = 1)
        endif
        if keyword_set(timestamps) then begin
           ;;-->This may be possible with fill_background and
           ;;   fill_color properties in text().
           ply_x0 = 0.07
           ply_y0 = 0.85
           ply_dx = 0.25
           ply_dy = 0.08
           ply = polygon([ply_x0,ply_x0+ply_dx,ply_x0+ply_dx,ply_x0], $
                         [ply_y0,ply_y0,ply_y0+ply_dy,ply_y0+ply_dy], $
                         /normal, $
                         fill_color = 'white', $
                         linestyle = 0, $
                         thick = 2)
           timeText = "it = "+strcompress(it,/remove_all)
           txt = text(ply_x0+0.01, $
                      ply_y0+0.02, $
                      timeText, $
                      /normal, $
                      color = 'black', $
                      alignment = 0.0, $
                      vertical_alignment = 0.0, $
                      font_name = 'Times', $
                      font_size = 12)
        endif
        frame = img.copywindow()
        !NULL = video.put(stream,frame)
        img.close
     endfor

     ;;==Close video stream
     video.cleanup
     printf, lun,"[DATA_MOVIE] Finished"

  endif $
  else printf, lun,"[DATA_MOVIE] movdata must have dimensions (x,y,t)"

end
