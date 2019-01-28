function video_plot_frame, xin,yin, $
                           legend=lkw_in, $
                           text=tkw_in, $
                           _REF_EXTRA=ex

  if n_elements(lkw_in) ne 0 then lkw = lkw_in[*]
  if n_elements(tkw_in) ne 0 then tkw = tkw_in[*]

  if n_elements(lkw) eq 0 then $
     lkw = dictionary('add',0)
  if ~lkw.haskey('add') then $
     lkw['add'] = 0
  if n_elements(tkw) eq 0 then $
     tkw = dictionary('add',0)
  if ~tkw.haskey('add') then $
     tkw['add'] = 0

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

  if lkw.add then begin
     lkw.remove, 'add'
     leg = legend(target = frm, $
                  _EXTRA = lkw.tostruct())
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
