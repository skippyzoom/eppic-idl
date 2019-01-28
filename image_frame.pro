function video_image_frame, fin,xin,yin, $
                           colorbar=ckw_in, $
                           text=tkw_in, $
                           _REF_EXTRA=ex

  if n_elements(ckw_in) ne 0 then ckw = ckw_in[*]
  if n_elements(tkw_in) ne 0 then tkw = tkw_in[*]

  if n_elements(ckw) eq 0 then $
     ckw = dictionary('add',0)
  if ~ckw.haskey('add') then $
     ckw['add'] = 0
  if n_elements(tkw) eq 0 then $
     tkw = dictionary('add',0)
  if ~tkw.haskey('add') then $
     tkw['add'] = 0  

  if n_elements(xin) ne 0 && n_elements(yin) ne 0 then begin
     frm = image(fin,xin,yin, $
                 /buffer, $
                 _STRICT_EXTRA = ex)
  endif $
  else begin
     frm = image(fin, $
                 /buffer, $
                 _STRICT_EXTRA = ex)
  endelse

  if ckw.add then begin
     ckw.remove, 'add'
     clr = colorbar(target = frm, $
                    _EXTRA = ckw.tostruct())
  endif

  if tkw.add then begin
     tkw.remove, 'add'
     txyz = tkw.xyz
     if n_elements(txyz) eq 2 then txyz = [txyz,0]
     tkw.remove, 'xyz'
     tstr = tkw.string
     tkw.remove, 'string'
     tfmt = tkw.format
     tkw.remove, 'format'
     txt = text(txyz[0],txyz[1],txyz[2],tstr,tfmt, $
                target = frm, $
                _EXTRA = tkw.tostruct())
  endif

  return, frm
end
