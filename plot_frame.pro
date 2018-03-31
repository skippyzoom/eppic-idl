function plot_frame, xdata,ydata, $
                     title=title, $
                     plot_kw=plot_kw, $
                     legend_kw=legend_kw, $
                     add_legend=add_legend, $
                     text_kw=text_kw

  if n_elements(title) ne 0 then plot_kw['title'] = title[it]
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
  plt = plot(xdata,ydata, $
             /buffer, $
             _EXTRA=plot_kw.tostruct())
  if n_elements(legend_kw) ne 0 then $
     leg = legend(target = plt, $
                  _EXTRA = legend_kw.tostruct()) $
  else if keyword_set(add_legend) then $
     leg = legend(target = plt, $
                  orientation = orientation)
  if n_elements(text_string) ne 0 then begin
     txt = text(text_pos[0],text_pos[1],text_pos[2], $
                text_string[it], $
                text_format, $
                _EXTRA = text_kw.tostruct())
  endif

  return, plt
end
