;+
; Save an image or plot frame based on file extension.
;
; This function saves an image or plot frame, given the object
; reference returned by image() or plot(). This function accepts any
; extension accepted by the IDL save method. See the IDL help page for
; 'save_method' for more information. If this function doesn't
; recognize the file extension, it will issue a warning and use '.png' 
; as the extension.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FRAME (required)
;    The object reference returned by a call to image() or plot().
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; FILENAME (default: 'new_frame.png')
;    The name that the resultant graphics file will have.
;-
pro frame_save, frame, $
                lun=lun, $
                filename=filename, $
                ;; time_stamp=time_stamp, $
                ;; path_stamp=path_stamp, $
                text_xyz=text_xyz, $
                text_string=text_string, $
                text_format=text_format, $
                text_kw=text_kw, $
                _EXTRA=ex

  ;;==List IDL-supported file types
  types = ['bmp', $                ;Windows bitmap
           'emf', $                ;Windows enhanced metafile
           'eps','ps', $           ;Encapsulated PostScript
           'gif', $                ;GIF frame
           'jpg','jpeg', $         ;JPEG frame
           'jp2','jpx','j2k', $    ;JPEG2000 frame
           'kml', $                ;OGC Keyhole Markup Language
           'kmz', $                ;A compressed and zipped version of KML
           'pdf', $                ;Portable document format
           'pict', $               ;Macintosh PICT frame
           'png', $                ;PNG frame
           'svg', $                ;Scalable Vector Graphics
           'tif','tiff']           ;TIFF frame

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(filename) eq 0 then filename = 'new_frame.png'
  if keyword_set(time_stamp) || keyword_set(path_stamp) then begin
     if n_elements(text_xyz) eq 0 then text_xyz = [0,0,0]
     ;; if n_elements(text_string) eq 0 then text_string = ''
     if n_elements(text_format) eq 0 then text_format = 'k'
  endif

  ;;==Make sure target directory exists
  if ~file_test(file_dirname(filename),/directory) then $
     spawn, 'mkdir -p '+file_dirname(filename)

  ;;==Get file extension from filename
  ext = get_extension(filename)
  supported = string_exists(types,ext,/fold_case)
  if ~supported then begin
     printf, lun,"[FRAME_SAVE] File type not recognized or not supported." 
     printf, lun,"             Using PNG."
     filename = strip_extension(filename)+'.png'
  endif

  ;;==Save frame
  case n_elements(frame) of
     0: begin
        printf, lun,"[FRAME_SAVE] Invalid frame handle."
        printf, lun,"             Did not save ",filename,"."
     end
     1: begin
        if n_elements(text_string) ne 0 then begin
           txt = text(text_xyz[0],text_xyz[1],text_xyz[2], $
                      text_string, $
                      text_format, $
                      target = frame, $
                      _EXTRA = text_kw.tostruct())
        endif
        printf, lun,"[FRAME_SAVE] Saving ",filename,"..."
        frame.save, filename,_EXTRA=ex
        if strcmp(ext,'pdf') || strcmp(ext,'gif') then frame.close
        printf, lun,"[FRAME_SAVE] Finished."
     end
     else: begin
        if ~strcmp(ext,'pdf') && ~strcmp(ext,'gif') then begin
           printf, lun,"[FRAME_SAVE] Multipage frames must be .pdf or .gif"
           printf, lun,"             Please change the file type or pass a"
           printf, lun,"             single file handle."
        endif $
        else begin
           printf, lun,"[FRAME_SAVE] Saving ",filename,"..."
           n_pages = n_elements(frame)
           for ip=0,n_pages-1 do frame[ip].save, filename,_EXTRA=ex,/append, $
              close = (ip eq n_pages-1)
           printf, lun,"[FRAME_SAVE] Finished."
        endelse
     end
  endcase

end
