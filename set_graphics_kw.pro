;+
; Function for setting graphics keyword dictionaries.
;
; This function returns dictionaries of image, colorbar, and text
; keywords to be passed to graphics routines like data_frame.pro
; and data_movie.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA_NAME (required)
;    The name of the data quantity for which to set up keywords.
; DATA (optional)
;    An array containing the data. If the user supplies the data
;    array, this function will use it to calculate keywords like
;    min/max color values.
; CONTEXT (default: 'spatial')
;    This keywords selects between keywords for spatial or spectral
;    graphics.
; <return>
;    Dictionaries of graphics keywords for image, colorbar, and
;    text functions.
;-
function set_graphics_kw, data_name,data, $
                          context=context

  ;;==Defaults and guards
  if n_elements(context) eq 0 then context = 'spatial'

  ;;==Get data array dimensions
  if n_elements(data) ne 0 then begin
     dsize = size(data)
     nx = dsize[1]
     ny = dsize[2]
     data_aspect = float(ny)/nx
  endif

  ;;==Set number of x and y ticks
  xmajor = 5
  xminor = 1
  ymajor = 5
  yminor = 1

  ;; ;;==Compute locations of x and y tick marks
  ;; xtickvalues = nx*indgen(xmajor)/(xmajor-1)
  ;; ytickvalues = ny*indgen(ymajor)/(ymajor-1)

  ;;==Set x and y titles
  if strcmp(context,'spectral') then begin
     xtitle = '$k_{Zon}$ [m$^{-1}$]'
     ytitle = '$k_{Ver}$ [m$^{-1}$]'
     ;; xtickname = strarr(xmajor)
     ;; inds = strcompress(1+indgen(xmajor/2),/remove_all)
     ;; if xmajor mod 2 then begin
     ;;    xtickname[xmajor/2] = '0'
     ;;    for ix=1,xmajor/2 do begin
     ;;       xtickname[xmajor/2-ix] = '-'+inds[ix-1]+'$\pi$'
     ;;       xtickname[xmajor/2+ix] = '+'+inds[ix-1]+'$\pi$'
     ;;    endfor
     ;; endif $
     ;; else begin
     ;;    for ix=0,xmajor-1 do begin
     ;;       xtickname[ix] = '-'+inds[ix]+'$\pi$'
     ;;       xtickname[xmajor-ix] = '+'+inds[ix]+'$\pi$'
     ;;    endfor
     ;; endelse
  endif else begin
     xtitle = 'Zonal [m]'
     ytitle = 'Vertical [m]'
  endelse

  ;;==Set colorbar tickmarks
  ;;-->Use plusminus_labels.pro

  ;;==Set graphics preferences
  img_pos = [0.10,0.10,0.80,0.80]
  clr_pos = [0.82,0.10,0.84,0.80]
  image_kw = dictionary('axis_style', 1, $
                        'position', img_pos, $
                        'xtitle', xtitle, $
                        'ytitle', ytitle, $
                        'xstyle', 1, $
                        'ystyle', 1, $
                        'xmajor', xmajor, $
                        'xminor', xminor, $
                        'ymajor', ymajor, $
                        'yminor', yminor, $
                        'xticklen', 0.02, $
                        'yticklen', 0.02*data_aspect, $
                        'xsubticklen', 0.5, $
                        'ysubticklen', 0.5, $
                        'xtickdir', 1, $
                        'ytickdir', 1, $
                        'xtickvalues', xtickvalues, $
                        'ytickvalues', ytickvalues, $
                        'xtickname', xtickname, $
                        'ytickname', ytickname, $
                        'xtickfont_size', 20.0, $
                        'ytickfont_size', 20.0, $
                        'font_size', 24.0, $
                        'font_name', "Times")
  colorbar_kw = dictionary('orientation', 1, $
                           'textpos', 1, $
                           'font_size', 24.0, $
                           'font_name', "Times", $
                           'position', clr_pos)
  text_kw = dictionary('font_name', 'Times', $
                       'font_size', 24, $
                       'font_color', 'black', $
                       'normal', 1B, $
                       'alignment', 0.0, $
                       'vertical_alignment', 0.0, $
                       'fill_background', 1B, $
                       'fill_color', 'powder blue')
  if strcmp(data_name,'den',3) then begin
     if n_elements(data) ne 0 then begin
        image_kw['min_value'] = -max(abs(data[*,*,1:*]))
        image_kw['max_value'] = +max(abs(data[*,*,1:*]))
     endif
     image_kw['rgb_table'] = 5
     colorbar_kw['title'] = '$\delta n/n_0$'
  endif
  if strcmp(data_name,'phi') then begin
     if n_elements(data) ne 0 then begin
        image_kw['min_value'] = -max(abs(data[*,*,1:*]))
        image_kw['max_value'] = +max(abs(data[*,*,1:*]))
     endif
     ct = get_custom_ct(1)
     image_kw['rgb_table'] = [[ct.r],[ct.g],[ct.b]]
     colorbar_kw['title'] = '$\phi$ [V]'
  endif
  if strcmp(data_name,'Ex') || $
     strcmp(data_name,'efield_x') then begin
     if n_elements(data) ne 0 then begin
        image_kw['min_value'] = -max(abs(data[*,*,1:*]))
        image_kw['max_value'] = +max(abs(data[*,*,1:*]))
     endif
     image_kw['rgb_table'] = 5
     colorbar_kw['title'] = '$\delta E_x$ [V/m]'
  endif
  if strcmp(data_name,'Ey') || $
     strcmp(data_name,'efield_y') then begin
     if n_elements(data) ne 0 then begin
        image_kw['min_value'] = -max(abs(data[*,*,1:*]))
        image_kw['max_value'] = +max(abs(data[*,*,1:*]))
     endif
     image_kw['rgb_table'] = 5
     colorbar_kw['title'] = '$\delta E_y$ [V/m]'
  endif
  if strcmp(data_name,'Ez') || $
     strcmp(data_name,'efield_z') then begin
     if n_elements(data) ne 0 then begin
        image_kw['min_value'] = -max(abs(data[*,*,1:*]))
        image_kw['max_value'] = +max(abs(data[*,*,1:*]))
     endif
     image_kw['rgb_table'] = 5
     colorbar_kw['title'] = '$\delta E_z$ [V/m]'
  endif
  if strcmp(data_name,'Er') || $
     strcmp(data_name,'efield_r',strlen('efield_r')) || $
     strcmp(data_name,'efield') then begin
        image_kw['min_value'] = 0
     if n_elements(data) ne 0 then $
        image_kw['max_value'] = max(data[*,*,1:*])
     image_kw['rgb_table'] = 3
     colorbar_kw['title'] = '$|\delta E|$ [V/m]'
  endif
  if strcmp(data_name,'Et') || $
     strcmp(data_name,'efield_t',strlen('efield_t')) then begin
     image_kw['min_value'] = -!pi
     image_kw['max_value'] = +!pi
     ct = get_custom_ct(2)
     image_kw['rgb_table'] = [[ct.r],[ct.g],[ct.b]]
     colorbar_kw['title'] = '$tan^{-1}(\delta E_y,\delta E_x)$ [rad.]'
  endif
  if strcmp(context,'spectral') then begin
     image_kw['min_value'] = -30
     image_kw['max_value'] = 0
     image_kw['rgb_table'] = 39
     colorbar_kw['title'] = 'Power [dB]'
  endif

  return, dictionary('image',image_kw, $
                     'colorbar',colorbar_kw, $
                     'text',text_kw)
end
