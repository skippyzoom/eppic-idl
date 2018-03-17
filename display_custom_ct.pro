;+
; Display the available color tables defined in get_custom_ct.pro
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;
;-
pro display_custom_ct

  n_tables = n_elements(get_custom_ct(/list))
  for it=0,n_tables-1 do begin
     ct = get_custom_ct(it)
     rgb_table = [[ct.r],[ct.g],[ct.b]]
     cdata = intarr(16,256)
     for ic=0,255 do cdata[*,ic] = ic
     help, it
     img = image(cdata, $
                 layout = [n_tables,1,it+1], $
                 rgb_table = rgb_table, $
                 title = "Table "+strcompress(it,/remove_all), $
                 current = (ic gt 1), $
                 /buffer)
  endfor
  image_save, img, $
              filename = expand_path('~/idl/custom_color_tables.pdf')

end
