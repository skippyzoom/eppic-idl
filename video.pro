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

;;=>Strategy: 
;;Let the user provide optional graphics keywords (e.g., xtitle,
;;axis_style) directly, thereby passing them through _EXTRA. If the
;;user wants to add a simple legend in plot mode, they can set
;;/legend; if they want to customize the legend, they can supply a
;;dictionary of keywords via legend; similarly for a colorbar in
;;image mode. If the user wants to add text to the movie, they can
;;supply a dictionary containing parameters and keywords via
;;text. In that case, the user-supplied dictionary must contain a
;;member called 'xyz' for position and a member called 'string' for
;;the text string. It may also contain an optional member called 
;;'format' for the text format. This naming convention is consistent
;;with the names of the two required and one optional parameters as
;;described on the IDL man page for text.pro.

;;=>To do:
;;1) Decide what the return value/object should be.
;;2) Distinguish between QUIET and VERBOSE.

function video, arg1,arg2,arg3, $
                verbose=verbose, $
                quiet=quiet, $
                lun=lun, $
                filename=filename, $
                framerate=framerate, $
                resize=resize, $
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

  ;;==Determine image/plot mode from input dimensions
  sarg1 = size(arg1)
  case sarg1[0] of
     1: begin
        arg1_is_x_axis = 1B
        sarg2 = size(arg2)
        if sarg2[0] ne 0 then begin
           mode = 'plot'
           nx = n_elements(arg1)
           ny = sarg2[1]
           nt = sarg2[2]
        endif else mode = 'error'
     end
     2: begin
        arg1_is_x_axis = 0B
        mode = 'plot'
        ny = sarg1[1]
        nx = ny
        nt = sarg1[2]
     end
     3: begin
        mode = 'image'
        nx = sarg1[1]
        ny = sarg1[2]
        nt = sarg1[3]
     end
     else: mode = 'error'
  endcase

  ;;==Warn the user that idlffvideowrite::put will throw an error if
  ;;  either nx < 30 or ny < 30.
  if (nx lt 30) || (ny lt 30) then begin
     if nx lt 30 then begin
        msg = "[VIDEO] idlffvideowrite::put requires nx > 29. Consider using resize > 1."
        printf, lun,msg
        mode = 'error'
     endif
     if ny lt 30 then begin
        msg = "[VIDEO] idlffvideowrite::put requires ny > 29. Consider using resize > 1."
        printf, lun,msg
        mode = 'error'
     endif
     if (nx lt 30) && (ny lt 30) then begin
        msg = "[VIDEO] idlffvideowrite::put requires [nx,ny] > [29,29]. "+ $
              "Consider using resize > 1."
        printf, lun,msg
        mode = 'error'
     endif
  endif

  ;;==If input is good, handle some graphics keywords
  if ~strcmp(mode,'error') then begin

     ;;==Extract a dictionary of graphics keywords
     if n_elements(ex) ne 0 then dex = dictionary(ex,/extract) $
     else dex = dictionary()

     ;;==Ensure proper video-frame dimensions
     if dex.haskey('dimensions') then dimensions = dex.dimensions $
     else dimensions = [nx,ny]
     dimensions = [dimensions[0]*resize[0], $
                   dimensions[1]*resize[1]]
     dex.dimensions = dimensions

     ;;==Remove time-dependent graphics keywords and reserve
     if dex.haskey('title') then begin
        case n_elements(dex.title) of 
           0: title = make_array(nt,value='')
           1: title = make_array(nt,value=dex.title)
           nt: title = dex.title
           else: !NULL
        endcase
        dex.remove, 'title'
     endif
     if n_elements(title) eq 0 then $
        title = make_array(nt,value='')

     ;;==Handle LEGEND (for plot movies)
     if key_value(dex,'legend') then begin
        case 1B of 
           isa(dex.legend,/number): legend = dictionary('add',1, $
                                                        'orientation',0)
           isa(dex.legend,'dictionary'): legend = (dex.legend)[*]
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
        dex.remove, 'legend'
     endif

     ;;==Handle COLORBAR (for image movies)
     if key_value(dex,'colorbar') then begin
        case 1B of 
           isa(dex.colorbar,/number): colorbar = dictionary('add',1, $
                                                            'orientation',0)
           isa(dex.colorbar,'dictionary'): colorbar = (dex.colorbar)[*]
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
        dex.remove, 'colorbar'
     endif

     ;;==Handle TEXT
     if keyword_set(text) then begin
        if ~isa(text,'dictionary') then begin
           if ~keyword_set(quiet) then $
              printf, lun,'[VIDEO] TEXT must be a dictionary'
           text = dictionary('add',0)
        endif                
     endif $
     else begin
        text = dictionary('add',0, $
                          'string',!NULL, $
                          'xyz',!NULL)
     endelse
     if ~text.haskey('add') then text.add = 1B
     if ~text.haskey('xyz') then begin
        if ~keyword_set(quiet) then $
           printf, lun,'[VIDEO] TEXT requires an array of positions called XYZ'
        text.add = 0B
     endif $
     else begin
        case n_elements(text.xyz) of
           0: text.xyz = [0,0,0]
           2: text.xyz = [text.xyz,0]
           else: begin
              msg = "[VIDEO] TEXT.XYZ has an inappropriate number of elements. "+ $
                    "Using [0,0,0]"
              if ~keyword_set(quiet) then printf, lun,msg
              text.xyz = [0,0,0]
           end
        endcase
     endelse
     if ~text.haskey('string') then begin
        if ~keyword_set(quiet) then $
           printf, lun,'[VIDEO] TEXT requires a string called STRING'
        text.add = 0B
     endif $
     else begin
        case n_elements(text.string) of
           0: tstr = make_array(nt,value='')
           1: tstr = make_array(nt,value=text.string)
           nt: tstr = text.string
           else: tstr = !NULL
        endcase
     endelse

  endif                         ;Mode is not 'error'

  ;;==Create video or print error message and return
  case 1B of
     strcmp(mode,'plot'): begin        

        ;;==Open video stream
        printf, lun,"[VIDEO] Creating ",filename," in plot mode..."
        vobj = idlffvideowrite(filename)
        stream = vobj.addvideostream(dex.dimensions[0], $
                                     dex.dimensions[1], $
                                     framerate)

        ;;==Add frames to video stream
        if arg1_is_x_axis then begin
           xin = arg1
           yin = arg2
           if isa(arg3,/string) then format = arg3
        endif $
        else begin
           xin = !NULL
           yin = arg1
           if isa(arg2,/string) then format = arg2
        endelse

        for it=0,nt-1 do begin
           dex.title = title[it]
           text.string = tstr[it]
           frm = plot_frame(xin,yin[*,it],format, $
                            legend = legend, $
                            text = text, $
                            _REF_EXTRA = dex.tostruct())
           frame = frm.copywindow()
           vtime = vobj.put(stream,frame)
           frm.close
        endfor

        ;;==Close video stream
        vobj.cleanup
        printf, lun,"[VIDEO] Finished"

     end
     strcmp(mode,'image'): begin

        ;;==Open video stream
        printf, lun,"[VIDEO] Creating ",filename," in image mode..."
        vobj = idlffvideowrite(filename)
        stream = vobj.addvideostream(dex.dimensions[0], $
                                     dex.dimensions[1], $
                                     framerate)

        ;;==Add frames to video stream
        for it=0,nt-1 do begin
           dex.title = title[it]           
           text.string = tstr[it]
           frm = image_frame(arg1[*,*,it],arg2,arg3, $
                             colorbar = colorbar, $
                             text = text, $
                             _REF_EXTRA = dex.tostruct())
           frame = frm.copywindow()
           vtime = vobj.put(stream,frame)
           frm.close
        endfor

        ;;==Close video stream
        vobj.cleanup
        printf, lun,"[VIDEO] Finished"

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

  return_info = dictionary('mode',mode, $
                           'filename',filename, $
                           'input_keywords',ex)
  return, return_info
end
