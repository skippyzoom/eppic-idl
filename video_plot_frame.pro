function video_plot_frame, xin,yin, $
                           _legend=_legend, $
                           _text=_text, $
                           _REF_EXTRA=ex

  if n_elements(_legend) eq 0 then $
     _legend = dictionary('add',0)
  if n_elements(_text) eq 0 then $
     _text = dictionary('add',0)

  if n_elements(xin) ne 0 then begin
     frm = plot(xin,yin, $
                /buffer, $
                _STRICT_EXTRA = ex)
  endif $
  else begin
     frm = plot(yin, $
                /buffer, $
                _STRICT_EXTRA = ex)
  endelse

  if _legend.add then begin
     _legend.remove, 'add'
     leg = legend(target = frm, $
                  _EXTRA = _legend.tostruct())
  endif

  if _text.add then begin
     txyz = _text.xyx
     _text.remove, 'xyz'
     tstr = _text.string
     _text.remove, 'string'
     tfmt = _text.format
     _text.remove, 'format'
     txt = text(txyz[0],txyz[1],txyz[2],tstr,tfmt, $
                target = frm, $
                _EXTRA = _text.tostruct())
  endif

  return, frm
end
