;+
; Create and save a movie of an EPPIC data quantity
;
; This routine reads time-dependent data of a single 2-D
; plane from 2-D or 3-D HDF files produced by EPPIC, then
; creates a movie of that (2+1)-D data array.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA_NAME
;    The name of the data quantity to read. If the data
;    does not exist, read_ph5_plane.pro will return 0
;    and this routine will exit gracefully.
; AXES (default: 'xy')
;    Simulation axes to extract from HDF data. If the
;    simulation is 2 D, read_ph5_plane.pro will ignore
;    this parameter.
; DATA_TYPE (default: 4)
;    IDL numerical data type of simulation output, 
;    typically either 4 (float) for spatial data
;    or 6 (complex) for Fourier-transformed data.
; DATA_ISFT (default: 0)
;    Boolean that represents whether the EPPIC data 
;    quantity is Fourier-transformed or not.
; ROTATE (default: 0)
;    Integer indcating whether, and in which direction,
;    to rotate the data array and axes before creating a
;    movie. This parameter corresponds to the 'direction'
;    parameter in IDL's rotate.pro.
; FFT_DIRECTION (default: 0)
;    Integer indicating whether, and in which direction,
;    to calculate the FFT of the data before creating a
;    movie. Setting fft_direction = 0 results in no FFT.
; INFO_PATH (default: './')
;    Fully qualified path to the simulation parameter
;    file (ppic3d.i or eppic.i).
; DATA_PATH (default: './')
;    Fully qualified path to the simulation data.
; SAVE_PATH (default: './')
;    Fully qualified path to the location in which to save
;    the output movie. If the path does not exist, this 
;    routine will create it.
; SAVE_NAME (default: 'data_movie.mp4')
;    Name of the movie.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
;-
pro eppic_movie, data_name, $
                 axes=axes, $
                 ranges=ranges, $
                 data_type=data_type, $
                 data_isft=data_isft, $
                 rotate=rotate, $
                 fft_direction=fft_direction, $
                 info_path=info_path, $
                 data_path=data_path, $
                 save_path=save_path, $
                 save_name=save_name, $                 
                 lun=lun, $
                 _EXTRA=ex

  ;;==Defaults and guards
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(ranges) eq 0 then ranges = [0,1,0,1]
  if n_elements(data_type) eq 0 then data_type = 4
  if n_elements(data_isft) eq 0 then data_isft = 0B
  if n_elements(rotate) eq 0 then rotate = 0
  if n_elements(fft_direction) eq 0 then fft_direction = 0
  if n_elements(info_path) eq 0 then info_path = './'
  if n_elements(data_path) eq 0 then data_path = './'
  if n_elements(save_path) eq 0 then save_path = './'
  if ~file_test(save_path,/directory) then $
     spawn, 'mkdir -p '+expand_path(save_path)
  if n_elements(save_name) eq 0 then save_name = 'data_movie.mp4'
  if n_elements(lun) eq 0 then lun = -1

  ;;==Declare the movie file name
  filename = expand_path(save_path+path_sep()+save_name)

  ;;==Read simulation parameters
  params = set_eppic_params(path=info_path)

  ;;==Convert ranges to physical indices
  case 1B of
     strcmp(axes,'xy'): begin
        x0 = params.nx*params.nsubdomains*ranges[0]/params.nout_avg
        xf = params.nx*params.nsubdomains*ranges[1]/params.nout_avg
        y0 = params.ny*ranges[2]/params.nout_avg
        yf = params.ny*ranges[3]/params.nout_avg
        dx = params.dx
        dy = params.dy
     end
     strcmp(axes,'xz'): begin
        x0 = params.nx*params.nsubdomains*ranges[0]/params.nout_avg
        xf = params.nx*params.nsubdomains*ranges[1]/params.nout_avg
        y0 = params.nz*ranges[2]/params.nout_avg
        yf = params.nz*ranges[3]/params.nout_avg
        dx = params.dx
        dy = params.dz
     end
     strcmp(axes,'yz'): begin
        x0 = params.ny*ranges[0]/params.nout_avg
        xf = params.ny*ranges[1]/params.nout_avg
        y0 = params.nz*ranges[2]/params.nout_avg
        yf = params.nz*ranges[3]/params.nout_avg
        dx = params.dy
        dy = params.dz
     end
  endcase
  x0 = fix(x0)
  xf = fix(xf)
  y0 = fix(y0)
  yf = fix(yf)

  ;;==Calculate max number of time steps
  nt_max = calc_timesteps(path=info_path)

  ;;==Create the time-step array
  timestep = params.nout*lindgen(nt_max)
  nts = n_elements(timestep)

  ;;==Read data at each time step
  if strcmp(data_name,'e',1,/fold_case) then $
     read_name = 'phi' $
  else $
     read_name = data_name
  fdata = read_ph5_plane(read_name, $
                         ext = '.h5', $
                         timestep = timestep, $
                         axes = axes, $
                         data_type = data_type, $
                         data_isft = data_isft, $
                         data_path = data_path, $
                         info_path = info_path, $
                         ranges = ranges, $
                         /verbose)

  ;;==Check dimensions
  fsize = size(fdata)
  if fsize[0] eq 3 then begin

     ;;==Get dimensions of data array
     fsize = size(fdata)
     nx = fsize[1]
     ny = fsize[2]

     ;;==Create full arrays of x- and y-axis data points
     xdata = dx*(x0 + indgen(xf-x0))
     ydata = dy*(y0 + indgen(yf-y0))

     ;;==Rotate data, if requested
     if rotate gt 0 then begin
        if rotate mod 2 then begin
           tmp = ydata
           ydata = xdata
           xdata = tmp
           fsize = size(fdata)
           tmp = fdata
           fdata = make_array(fsize[2],fsize[1],nts,type=fsize[4],/nozero)
           for it=0,nts-1 do fdata[*,*,it] = rotate(tmp[*,*,it],rotate)
        endif $
        else begin
           for it=0,nts-1 do fdata[*,*,it] = rotate(fdata[*,*,it],rotate)
        endelse
     endif

     ;;==Get (possibly new) dimensions of data array
     fsize = size(fdata)
     nx = fsize[1]
     ny = fsize[2]

     ;;==Set number of x and y ticks
     xmajor = 5
     xminor = 1
     ymajor = 5
     yminor = 1

     ;; ;;==Compute locations of x and y tick marks
     ;; xtickvalues = nx*indgen(xmajor)/(xmajor-1)
     ;; ytickvalues = ny*indgen(ymajor)/(ymajor-1)

     ;;==Set x and y titles
     if fft_direction lt 0 or data_isft then begin
        xtitle = '$k_{Zon}$ [m$^{-1}$]'
        ytitle = '$k_{Ver}$ [m$^{-1}$]'
        xtickname = strarr(xmajor)
        inds = strcompress(1+indgen(xmajor/2),/remove_all)
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
        ;; endelse
     endif else begin
        xtitle = 'Zonal [m]'
        ytitle = 'Vertical [m]'
     endelse

     ;;==Calculate FFT, if requested
     if fft_direction ne 0 then begin
        for it=0,nts-1 do $
           fdata[*,*,it] = real_part(fft(fdata[*,*,it],fft_direction))
        if fft_direction lt 0 then begin
           fdata = shift(fdata,[nx/2,ny/2,0])
           fdata[nx/2-3:nx/2+3,ny/2-3:ny/2+3,*] = min(fdata)
           fdata /= max(fdata)
           fdata = 10*alog10(fdata^2)
        endif
     endif

     ;;==Calculate E, if necessary
     if strcmp(data_name,'e',1,/fold_case) then begin
        Ex = fltarr(size(fdata,/dim))
        Ey = fltarr(size(fdata,/dim))
        for it=0,nts-1 do begin
           gradf = gradient(fdata[*,*,it], $
                            dx = params.dx*params.nout_avg, $
                            dy = params.dy*params.nout_avg)
           Ex[*,*,it] = -1.0*gradf.x
           Ey[*,*,it] = -1.0*gradf.y
        endfor
     endif

     ;;==Convert time steps to strings
     str_time = strcompress(string(1e3*params.dt*timestep, $
                                   format='(f6.2)'),/remove_all)
     time_stamps = "t = "+str_time+" ms"

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
                           'yticklen', 0.02*(float(ny)/nx), $
                           'xsubticklen', 0.5, $
                           'ysubticklen', 0.5, $
                           'xtickdir', 1, $
                           'ytickdir', 1, $
                           'xtickfont_size', 20.0, $
                           'ytickfont_size', 20.0, $
                           'font_size', 24.0, $
                           'font_name', "Times")
     colorbar_kw = dictionary('orientation', 1, $
                              'textpos', 1, $
                              'position', clr_pos)
     text_pos = [0.05,0.85]
     text_string = time_stamps
     text_format = 'k'
     text_kw = dictionary('font_name', 'Times', $
                          'font_size', 24, $
                          'font_color', 'black', $
                          'normal', 1B, $
                          'alignment', 0.0, $
                          'vertical_alignment', 0.0, $
                          'fill_background', 1B, $
                          'fill_color', 'powder blue')
     if strcmp(data_name,'den',3) then begin
        image_kw['min_value'] = -max(abs(fdata[*,*,1:*]))
        image_kw['max_value'] = +max(abs(fdata[*,*,1:*]))
        image_kw['rgb_table'] = 5
        colorbar_kw['title'] = '$\delta n/n_0$'
     endif
     if strcmp(data_name,'phi') then begin
        image_kw['min_value'] = -max(abs(fdata[*,*,1:*]))
        image_kw['max_value'] = +max(abs(fdata[*,*,1:*]))
        ct = get_custom_ct(1)
        image_kw['rgb_table'] = [[ct.r],[ct.g],[ct.b]]
        colorbar_kw['title'] = '$\phi$ [V]'
     endif
     if strcmp(data_name,'Ex') || $
        strcmp(data_name,'efield_x') then begin
        fdata = Ex
        image_kw['min_value'] = -max(abs(fdata[*,*,1:*]))
        image_kw['max_value'] = +max(abs(fdata[*,*,1:*]))
        image_kw['rgb_table'] = 5
        colorbar_kw['title'] = '$\delta E_x$ [V/m]'
     endif
     if strcmp(data_name,'Ey') || $
        strcmp(data_name,'efield_y') then begin
        fdata = Ey
        image_kw['min_value'] = -max(abs(fdata[*,*,1:*]))
        image_kw['max_value'] = +max(abs(fdata[*,*,1:*]))
        image_kw['rgb_table'] = 5
        colorbar_kw['title'] = '$\delta E_y$ [V/m]'
     endif
     if strcmp(data_name,'Er') || $
        strcmp(data_name,'efield_r') || $
        strcmp(data_name,'efield') then begin
        fdata = sqrt(Ex^2 + Ey^2)
        image_kw['min_value'] = 0
        image_kw['max_value'] = max(fdata[*,*,1:*])
        image_kw['rgb_table'] = 3
        colorbar_kw['title'] = '$|\delta E|$ [V/m]'
     endif
     if strcmp(data_name,'Et') || $
        strcmp(data_name,'efield_t') then begin
        fdata = atan(Ey,Ex)
        image_kw['min_value'] = -!pi
        image_kw['max_value'] = +!pi
        ct = get_custom_ct(2)
        image_kw['rgb_table'] = [[ct.r],[ct.g],[ct.b]]
        colorbar_kw['title'] = '$tan^{-1}(\delta E_y,\delta E_x)$ [rad.]'
     endif
     if fft_direction ne 0 then begin
        image_kw['min_value'] = -30
        image_kw['max_value'] = 0
        image_kw['rgb_table'] = 39
        colorbar_kw['title'] = 'Power [dB]'
     endif

     ;;==Create and save the movie
     data_movie, fdata,xdata,ydata, $
                 lun = lun, $
                 filename = filename, $
                 image_kw = image_kw, $
                 colorbar_kw = colorbar_kw, $
                 text_pos = text_pos, $
                 text_string = text_string, $
                 text_format = text_format, $
                 text_kw = text_kw

  endif $
  else printf, lun, "[EPPIC_MOVIE] Could not create movie of "+data_name+"."
  
end
