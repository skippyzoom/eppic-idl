function video_plot_frame, arg1,arg2, $
                           _legend=_legend, $
                           _text=_text, $
                           _REF_EXTRA=ex

  if n_elements(_legend) eq 0 then $
     _legend = dictionary('add',0)
  if n_elements(_text) eq 0 then $
     _text = dictionary('add',0)

  if n_elements(arg2) ne 0 then begin
     plt = plot(arg1,arg2, $
                /buffer, $
                _STRICT_EXTRA = ex)
  endif $
  else begin
     plt = plot(arg1, $
                /buffer, $
                _STRICT_EXTRA = ex)
  endelse

  if _legend.add then begin
     _legend.remove, 'add'
     leg = legend(target = plt, $
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
                target = plt, $
                _EXTRA = _text.tostruct())
  endif

  return, plt
end
