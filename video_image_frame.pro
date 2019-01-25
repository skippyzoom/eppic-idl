function video_image_frame, arg1,arg2,arg3, $
                           _colorbar=_colorbar, $
                           _text=_text, $
                           _REF_EXTRA=ex

  if n_elements(_colorbar) eq 0 then $
     _colorbar = dictionary('add',0)
  if n_elements(_text) eq 0 then $
     _text = dictionary('add',0)

  if n_elements(arg2) ne 0 && n_elements(arg3) ne 0 then begin
     frm = image(arg1,arg2,arg3, $
                 /buffer, $
                 _STRICT_EXTRA = ex)
  endif $
  else begin
     frm = image(arg1, $
                 /buffer, $
                 _STRICT_EXTRA = ex)
  endelse
  if _colorbar.add then begin
     _colorbar.remove, 'add'
     leg = colorbar(target = frm, $
                    _EXTRA = _colorbar.tostruct())
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
