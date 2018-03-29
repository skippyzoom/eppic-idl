;+
; Save an image based on file extension.
;
; This function saves an image, given the object reference 
; returned by image(). This function accepts any extension 
; accepted by the IDL save method. See the IDL help page 
; for save_method for more information. If this function 
; doesn't recognize the file extension, it will issue a 
; warning and use '.png' as the extension.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; IMAGE (required)
;    The object reference returned by a call to image().
; FILENAME (default: 'new_image.png')
;    The name that the resultant image file will have.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
;-
pro image_save, image,filename=filename,lun=lun,_EXTRA=ex

  ;;==List IDL-supported file types
  types = ['bmp', $                ;Windows bitmap
           'emf', $                ;Windows enhanced metafile
           'eps','ps', $           ;Encapsulated PostScript
           'gif', $                ;GIF image
           'jpg','jpeg', $         ;JPEG image
           'jp2','jpx','j2k', $    ;JPEG2000 image
           'kml', $                ;OGC Keyhole Markup Language
           'kmz', $                ;A compressed and zipped version of KML
           'pdf', $                ;Portable document format
           'pict', $               ;Macintosh PICT image
           'png', $                ;PNG image
           'svg', $                ;Scalable Vector Graphics
           'tif','tiff']           ;TIFF image

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(filename) eq 0 then filename = 'new_image.png'

  ;;==Make sure target directory exists
  if ~file_test(file_dirname(filename),/directory) then $
     spawn, 'mkdir -p '+file_dirname(filename)

  ;;==Get file extension from filename
  ext = get_extension(filename)
  supported = string_exists(types,ext,/fold_case)
  if ~supported then begin
     printf, lun,"[IMAGE_SAVE] File type not recognized or not supported." 
     printf, lun,"             Using PNG."
     filename = strip_extension(filename)+'.png'
  endif

  ;;==Save image
  case n_elements(image) of
     0: begin
        printf, lun,"[IMAGE_SAVE] Invalid image hangle."
        printf, lun,"             Did not save ",filename,"."
     end
     1: begin
        printf, lun,"[IMAGE_SAVE] Saving ",filename,"..."
        image.save, filename,_EXTRA=ex
        if strcmp(ext,'pdf') || strcmp(ext,'gif') then image.close
        printf, lun,"[IMAGE_SAVE] Finished."
     end
     else: begin
        if ~strcmp(ext,'pdf') && ~strcmp(ext,'gif') then begin
           printf, lun,"[IMAGE_SAVE] Multipage images must be .pdf or .gif"
           printf, lun,"             Please change the file type or pass a"
           printf, lun,"             single file handle."
        endif $
        else begin
           printf, lun,"[IMAGE_SAVE] Saving ",filename,"..."
           n_pages = n_elements(image)
           for ip=0,n_pages-1 do image[ip].save, filename,_EXTRA=ex,/append, $
              close = (ip eq n_pages-1)
           printf, lun,"[IMAGE_SAVE] Finished."
        endelse
     end
  endcase

end
