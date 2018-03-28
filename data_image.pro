;+
; Routine for producing images of EPPIC data from a (2+1)-D array.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; IMGDATA (required)
;    A (2+1)-D array from which to make a image.
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
; FILENAME (default: 'data_image.pdf')
;    Name of resultant image file, including extension. This routine
;    will pass filename to image_save.pro, where IDL will use the 
;    extension to determine the file type. See the IDL help pages
;    for image.pro and save_method for more information on supported
;    file types. This routine will attemp to make the number of 
;    elements in filename consistent with the value of multi_page.
; MULTI_PAGE (default: unset)
;    Boolean keyword to toggle saving images as multiple pages in
;    a single document. Only allowed (per IDL) for .pdf and .gif
;    formats
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
; -- This routine assumes the final dimension of data 
;    is the time-step dimension. 
; -- This routine automatically sets the buffer keyword 
;    to 1B to ensure that the current frame goes to a 
;    buffer instead of printing to the screen. The latter 
;    would slow the process considerably and clutter the 
;    screen. 
;-
pro data_image, imgdata,xdata,ydata, $
                lun=lun, $
                log=log, $
                alog_base=alog_base, $
                filename=filename, $
                multi_page=multi_page, $
                resize=resize, $
                image_kw=image_kw, $
                add_colorbar=add_colorbar, $
                colorbar_kw=colorbar_kw, $
                text_pos=text_pos, $
                text_string=text_string, $
                text_format=text_format, $
                text_kw=text_kw, $
                _EXTRA=ex

  ;;==Default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get data size
  data_size = size(imgdata)
  n_dims = data_size[0]

  ;;==Check data size
  if n_dims eq 3 then begin
     nt = data_size[n_dims]
     nx = data_size[1]
     ny = data_size[2]

     ;;==Other defaults and guards
     if ~keyword_set(log) && n_elements(alog_base) ne 0 then $
        log = 1B
     if n_elements(alog_base) eq 0 then alog_base = '10'
     if n_elements(filename) eq 0 then filename = 'data_image.pdf'
     if n_elements(filename) eq 1 && ~keyword_set(multi_page) then begin
        str_ind = strcompress(sindgen(nt),/remove_all)
        filename = strip_extension(filename) + str_ind + $
                   '.'+get_extension(filename)
     endif
     if n_elements(filename) gt 1 && keyword_set(multi_page) then begin
        printf, lun,"[DATA_IMAGE] Warning: Using "+filename[0]
        printf, lun,"             for all multi-page image."
        filename = filename[0]
     endif
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
           printf, lun,"[DATA_IMAGE] Did not recognize value of add_colorbar"
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
           printf, lun,"[DATA_IMAGE] Cannot use text_string for text."
           printf, lun,"             Please provide a single string"
           printf, lun,"             or an array with one element per"
           printf, lun,"             time step."
           make_text = 0B
        end
     endcase
     if n_elements(text_format) eq 0 then text_format = 'k'
     if n_elements(text_kw) eq 0 then text_kw = dictionary()

     ;;==Loop over time steps
     for it=0,nt-1 do begin
        if n_elements(title) ne 0 then image_kw['title'] = title[it]
        fdata = imgdata[*,*,it]
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
        img = image(fdata,xdata,ydata, $
                    /buffer, $
                    _EXTRA=image_kw.tostruct())
        if n_elements(colorbar_kw) ne 0 then $
           clr = colorbar(target = img, $
                          _EXTRA = colorbar_kw.tostruct()) $
        else if keyword_set(add_colorbar) then $
           clr = colorbar(target = img, $
                          orientation = orientation)
        if n_elements(text_string) ne 0 then begin
           txt = text(text_pos[0],text_pos[1],text_pos[2], $
                      text_string[it], $
                      text_format, $
                      _EXTRA = text_kw.tostruct())
        endif
        if ~keyword_set(multi_page) then $
           image_save, img, $
                       filename = filename[it], $
                       lun = lun
     endfor
     if keyword_set(multi_page) then $
        image_save, img, $
                    filename = filename, $
                    lun = lun

  endif  $
  else printf, lun,"[DATA_IMAGE] image data must have dimensions (x,y,t)"

end
