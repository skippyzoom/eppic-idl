;+
; Create a video from plot data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
;-
function plot_video, arg1,arg2,arg3, $
                     lun=lun, $
                     quiet=quiet, $
                     filename=filename, $
                     framerate=framerate, $
                     resize=resize, $
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

  success = 1B

  case n_params() of
     1: begin
        if isa(arg1,/float,/array) then begin
           xdata = !NULL
           ydata = arg1
           format = ''
        endif $
        else begin
           msg = "[PLOT_VIDEO] Could not recognize type of argument 1."
           if ~keyword_set(quiet) then printf, lun,msg
           success = 0B
        endelse
     end
     2: begin
        case 1B of
           isa(arg2,/string): begin
              xdata = !NULL
              ydata = arg1
              format = arg2
           end
           isa(arg2,/float,/array): begin
              xdata = arg1
              ydata = arg2
              format = ''
           end
           else: begin
              msg = "[PLOT_VIDEO] Could not recognize type of argument 2."
              if ~keyword_set(quiet) then printf, lun,msg
              success = 0B
           end
        endcase
     end
     3: begin
        if isa(arg1,/float,/array) && isa(arg2,/float,/array) && $
           isa(arg3,/string) then begin
           xdata = arg1
           ydata = arg2
           format = arg3
        endif $
        else begin
           msg = "[PLOT_VIDEO] Incorrect call sequence."
           if ~keyword_set(quiet) then printf, lun,msg
           success = 0B
        endelse
     end
  endcase

  xsize = size(xdata)
  ysize = size(ydata)
  ny = ysize[1]
  nt = ysize[2]
  if xsize[0] eq 0 then nx = ny $
  else nx = xsize[1]

  ;;==Warn the user that idlffvideowrite::put will throw an error if
  ;;  either nx < 30 or ny < 30.
  if (nx lt 30) || (ny lt 30) then begin
     if nx lt 30 then $
        msg = "[PLOT_VIDEO] idlffvideowrite::put requires nx > 29. "+ $
              "Consider using resize > 1."
     if ny lt 30 then $
        msg = "[PLOT_VIDEO] idlffvideowrite::put requires ny > 29. "+ $
              "Consider using resize > 1."
     if (nx lt 30) && (ny lt 30) then $
        msg = "[PLOT_VIDEO] idlffvideowrite::put requires [nx,ny] > "+ $
              "[29,29]. Consider using resize > 1."
     if ~keyword_set(quiet) then printf, lun,msg
     success = 0B
  endif

  if success then begin

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

     ;;==Handle LEGEND
     if dex.haskey('legend') then begin
        add_legend = 1B
        case 1B of 
           isa(dex.legend,/number): lkw = dictionary()
           isa(dex.legend,'dictionary'): lkw = (dex.legend)[*]
           else: begin
              msg = "[PLOT_VIDEO] "+ $
                    "LEGEND may be set as a boolean (/legend), "+cr+ $
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
     endif $
     else add_legend = 0B

     ;;==Handle TEXT
     if dex.haskey('text') then begin
        if isa(dex.text,'dictionary') then begin
           tkw = (dex.text)[*]
           dex.remove, 'text'
           add_text = 1B
           if tkw.haskey('xyz') then begin
              case n_elements(tkw.xyz) of
                 0: txyz = [0,0,0]
                 2: txyz = [tkw.xyz,0]
                 else: begin
                    msg = "[PLOT_VIDEO] "+ $
                          "TEXT.XYZ has an inappropriate "+ $
                          "number of elements. Using [0,0,0]"
                    if ~keyword_set(quiet) then printf, lun,msg
                    txyz = [0,0,0]
                 end
              endcase
              tkw.remove, 'xyz'
           endif $
           else begin
              if ~keyword_set(quiet) then begin
                 msg = "[PLOT_VIDEO] "+ $
                       "TEXT requires an array of positions called XYZ"
                 printf, lun,msg
              endif
              add_text = 0B
           endelse
           if tkw.haskey('string') then begin
              case n_elements(tkw.string) of
                 0: tstr = make_array(nt,value='')
                 1: tstr = make_array(nt,value=tkw.string)
                 nt: tstr = tkw.string
                 else: tstr = !NULL
              endcase              
              tkw.remove, 'string'
           endif $
           else begin
              if ~keyword_set(quiet) then $
                 printf, lun,'[PLOT_VIDEO] TEXT requires a string called STRING'
              add_text = 0B
           endelse
           if tkw.haskey('format') then begin
              tfmt = tkw.format
              tkw.remove, 'format'
           endif $
           else tfmt = ''        
        endif $
        else begin
           if ~keyword_set(quiet) then begin
              msg = "[PLOT_VIDEO] TEXT must be a dictionary"
              printf, lun,msg
           endif
           add_text = 0B
        endelse                
     endif $
     else add_text = 0B

     ;;==Open video stream
     printf, lun,"[PLOT_VIDEO] Creating ",filename,"..."
     vobj = idlffvideowrite(filename)
     stream = vobj.addvideostream(dex.dimensions[0], $
                                  dex.dimensions[1], $
                                  framerate)

     ;;==Add frames to video stream
     if add_text then begin
        if add_legend then begin
           for it=0,nt-1 do begin
              dex.title = title[it]
              frm = plot(xdata,ydata[*,it],format, $
                         /buffer, $
                         _EXTRA = dex.tostruct())
              leg = legend(target = frm, $
                           _EXTRA = lkw.tostruct())
              txt = text(txyz[0],txyz[1],txyz[2],tstr[it],tfmt, $
                         target = frm, $
                         _EXTRA = tkw.tostruct())
              frame = frm.copywindow()
              vtime = vobj.put(stream,frame)
              frm.close
           endfor
        endif $
        else begin
           for it=0,nt-1 do begin
              dex.title = title[it]
              frm = plot(xdata,ydata[*,it],format, $
                         /buffer, $
                         _EXTRA = dex.tostruct())
              txt = text(txyz[0],txyz[1],txyz[2],tstr[it],tfmt, $
                         target = frm, $
                         _EXTRA = tkw.tostruct())
              frame = frm.copywindow()
              vtime = vobj.put(stream,frame)
              frm.close
           endfor
        endelse
     endif $
     else begin
        if add_legend then begin
           for it=0,nt-1 do begin
              dex.title = title[it]
              frm = plot(xdata,ydata[*,it],format, $
                         /buffer, $
                         _EXTRA = dex.tostruct())
              leg = legend(target = frm, $
                           _EXTRA = lkw.tostruct())
              frame = frm.copywindow()
              vtime = vobj.put(stream,frame)
              frm.close
           endfor
        endif $
        else begin
           for it=0,nt-1 do begin
              dex.title = title[it]
              frm = plot(xdata,ydata[*,it],format, $
                         /buffer, $
                         _EXTRA = dex.tostruct())
              frame = frm.copywindow()
              vtime = vobj.put(stream,frame)
              frm.close
           endfor
        endelse
     endelse

     ;;==Close video stream
     vobj.cleanup
     printf, lun,"[PLOT_VIDEO] Finished"

  endif
  
  return, success
end
