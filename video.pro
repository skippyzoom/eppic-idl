;+
; Routine for producing movies of EPPIC data from a (2+1)-D array.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; ARG1 (required)
;    Either a (2+1)-D array from which to make images,
;    a (1+1)-D array from which to make plots, or a 1-D
;    array of x-axis points for making plots.
; ARG2 (optional)
;    Either a 1-D array of x-axis points for making images
;    or a (1+1)-D array from which to make plots when arg1
;    is a 1-D array of x-axis points.
; ARG3 (optional)
;    1-D array of y-axis points for making images.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This routine selects plot_graphics or image_graphics,
;    and the appropriate calling sequence, based on the dimensions 
;    of arg1, arg2, and arg3.
;-
function video, arg1,arg2,arg3, $
                verbose=verbose, $
                quiet=quiet, $
                lun=lun, $
                filename=filename, $
                log=log, $
                alog_base=alog_base, $
                framerate=framerate, $
                resize=resize, $
                ;; overplot=overplot, $
                ;; graphics_kw=graphics_kw, $
                ;; legend_kw=legend_kw, $
                ;; add_legend=add_legend, $
                ;; ;; plot_kw=plot_kw, $
                ;; ;; add_legend=add_legend, $
                ;; ;; legend_kw=legend_kw, $
                ;; ;; image_kw=image_kw, $
                ;; ;; add_colorbar=add_colorbar, $
                ;; ;; colorbar_kw=colorbar_kw, $
                ;; text_xyz=text_xyz, $
                ;; text_string=text_string, $
                ;; text_format=text_format, $
                ;; text_kw=text_kw, $
                legend=legend, $
                colorbar=colorbar, $
                text=text, $
                _EXTRA=ex

  ;;==Define carriage return
  cr = (!d.name eq 'WIN') ? string([13B,10B]) : string(10B)

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(filename) eq 0 then filename = 'video.mp4'
  if n_elements(framerate) eq 0 then framerate = 20
  if n_elements(resize) eq 0 then resize = [1.0, 1.0]
  if n_elements(resize) eq 1 then resize = [resize, resize]

  ;;==Make sure target directory exists
  if ~file_test(file_dirname(filename),/directory) then $
     spawn, 'mkdir -p '+file_dirname(filename)

  ;; ;;==Preserve input quantities
  ;; if keyword_set(graphics_kw) then _graphics_kw_ = graphics_kw[*]
  ;; if keyword_set(legend_kw) then _legend_kw_ = legend_kw[*]
  ;; if keyword_set(text_xyz) then _text_xyz_ = text_xyz
  ;; if keyword_set(text_string) then _text_string_ = text_string
  ;; if keyword_set(text_format) then _text_format_ = text_format
  ;; if keyword_set(text_kw) then _text_kw_ = text_kw[*]

  ;; d_ex = dictionary(ex,/extract)
  ;; if d_ex.haskey('graphics_kw') then graphics_kw = (d_ex.graphics_kw)[*]
  ;; if d_ex.haskey('image_kw') then graphics_kw = (d_ex.image_kw)[*]
  ;; if d_ex.haskey('plot_kw') then graphics_kw = (d_ex.plot_kw)[*]
  ;; if d_ex.haskey('legend_kw') then legend_kw = (d_ex.legend_kw)[*]
  ;; if d_ex.haskey('colorbar_kw') then legend_kw = (d_ex.colorbar_kw)[*]

  
  ;;==Strategy: 
  ;;Let the user provide optional graphics keywords (e.g., xtitle,
  ;;axis_style) directly, thereby passing them through _EXTRA. If the
  ;;user wants to add a simple legend in plot mode, they can set
  ;;/legend; if they want to customize the legend, they can supply a
  ;;dictionary of keywords via legend; similarly for a colorbar in
  ;;image mode. If the user wants to add text to the movie, they can
  ;;supply a dictionary containing parameters and keywords via
  ;;text. In that case, the user-supplied dictionary must contain a
  ;;member called 'xyz' for position, a member called 'string' for the
  ;;text string. It may also contain an optional member called
  ;;'format' for the text format. This naming convention is consistent
  ;;with the names of the two required and one optional parameters as
  ;;described on the IDL man page for text.pro.
  ;;three required parameter

  ;;==Handle LEGEND (for plot movies)
  if keyword_set(legend) then begin
     case 1B of 
        isa(legend,/number): legend = dictionary('add',1, $
                                                 'orientation',0)
        isa(legend,'dictionary'): legend['add'] = 1
        else: begin
           msg = "[VIDEO] LEGEND may be set as a boolean (/legend), "+cr+ $
                 "        "+ $
                 "a number (equivalent to setting /legend), or "+cr+ $
                 "        "+ $
                 "a dictionary of keywords. "+cr+ $
                 "        "+ $
                 "See the IDL help page for legend.pro for "+ $
                 "acceptible keywords."
           if ~keyword_set(quiet) then printf, lun,msg
        end
     endcase
  endif

  ;;==Handle COLORBAR (for image movies)
  if keyword_set(colorbar) then begin
     case 1B of 
        isa(colorbar,/number): colorbar = dictionary('add',1, $
                                                     'orientation',0)
        isa(colorbar,'dictionary'): colorbar['add'] = 1
        else: begin
           msg = "[VIDEO] COLORBAR may be set as a boolean (/colorbar), "+cr+ $
                 "        "+ $
                 "a number (equivalent to setting /colorbar), or "+cr+ $
                 "        "+ $
                 "a dictionary of keywords. "+cr+ $
                 "        "+ $
                 "See the IDL help page for colorbar.pro for "+ $
                 "acceptible keywords."
           if ~keyword_set(quiet) then printf, lun,msg
        end
     endcase
  endif

  ;;==Extract a dictionary of graphics keywords
  if n_elements(ex) ne 0 then begin
     dx = dictionary(ex,/extract)
     if dx.haskey('dimensions') then dimensions = dx.dimensions
  endif

  ;; if n_elements(dimensions) eq 0 then dimensions
STOP
  ;;==Determine image/plot mode from input dimensions
  case size(arg1,/n_dim) of
     1: begin
        sarg2 = size(arg2)
        if sarg2[0] ne 0 then begin
           mode = 'plot'
           nx = n_elements(arg1)
           ny = sarg2[1]
           axes_provided = 1B
        endif else mode = 'error'
        ;; mode = sarg2[0] ne 0 ? 'plot' : 'error'
     end
     2: begin
        mode = 'plot'
        axes_provided = 0B
     end
     3: begin
        mode = 'image'
        axes_provided = size(arg2,/n_dim) eq 1 && size(arg3,/n_dim) eq 1
     end
     else: mode = 'error'
  endcase

  ;;==Create video or print error message
  case 1B of
     strcmp(mode,'plot'): begin        
        ;;==Open video stream
        printf, lun,"[VIDEO] Creating ",filename," in plot mode..."
        ;; video = idlffvideowrite(filename)
        ;; stream = video.addvideostream(dimensions[0], $
        ;;                               dimensions[1], $
        ;;                               framerate)
     end
     strcmp(mode,'image'): begin
        ;;==Open video stream
        printf, lun,"[VIDEO] Creating ",filename," in image mode..."
        ;; video = idlffvideowrite(filename)
        ;; stream = video.addvideostream(dimensions[0], $
        ;;                               dimensions[1], $
        ;;                               framerate)
     end
     strcmp(mode,'error'): begin
        msg = "[VIDEO] Calling sequence may be either:"+cr+ $
              "        "+ $
              "IDL> video(xdata[,ydata][,kw/prop])"+cr+ $
              "        "+ $
              "with 1-D xdata and (1+1)-D ydata for plot frames"+cr+ $
              "        "+ $
              "                 **OR**"+cr+ $
              "        "+ $
              "IDL> video(fdata[,xdata][,ydata][,kw/prop])"+cr+ $
              "        "+ $
              "with (2+1)-D fdata, 1-D xdata, "+ $
              "and 1-D ydata for image frames"
        if ~keyword_set(quiet) then printf, lun,msg
     end
  endcase

  ;;==Close video stream
  video.cleanup
  printf, lun,"[VIDEO_IMAGE] Finished"

  ;; ;;==Reset input quantities
  ;; if keyword_set(graphics_kw) then _graphics_kw_ = graphics_kw[*]
  ;; if keyword_set(legend_kw) then _legend_kw_ = legend_kw[*]
  ;; if keyword_set(text_xyz) then _text_xyz_ = text_xyz
  ;; if keyword_set(text_string) then _text_string_ = text_string
  ;; if keyword_set(text_format) then _text_format_ = text_format
  ;; if keyword_set(text_kw) then _text_kw_ = text_kw[*]

  return_info = dictionary('mode',mode, $
                           'filename',filename, $
                           'input_keywords',ex)
  return, return_info
end
