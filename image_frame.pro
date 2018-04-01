function image_frame, fdata,xdata,ydata, $
                      title=title, $
                      image_kw=image_kw, $
                      colorbar_kw=colorbar_kw, $
                      add_colorbar=add_colorbar, $
                      text_kw=text_kw

  if n_elements(title) ne 0 then image_kw['title'] = title[it]
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

  return, img
end
