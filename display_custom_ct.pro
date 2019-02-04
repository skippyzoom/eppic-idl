;+
; Display the available color tables defined in get_custom_ct.pro
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NONE
;-
pro display_custom_ct

  ;;==Get the number of available tables
  n_tables = n_elements(get_custom_ct(/list))

  ;;==Loop over all available tables
  for it=0,n_tables-1 do begin

     ;;==Get the current custom table
     ct = get_custom_ct(it)

     ;;==Convert it into an RGB table
     rgb_table = [[ct.r],[ct.g],[ct.b]]

     ;;==Construct an image array
     cdata = intarr(16,256)

     ;;==Fill the array with colors
     for ic=0,255 do cdata[*,ic] = ic

     ;;==Create/update the image
     img = image(cdata, $
                 layout = [n_tables,1,it+1], $
                 rgb_table = rgb_table, $
                 title = "Table "+strcompress(it,/remove_all), $
                 current = (ic gt 1), $
                 /buffer)
  endfor

  ;;==Save the image frame
  frame_save, img, $
              filename = expand_path('~/idl/custom_color_tables.pdf')

end
