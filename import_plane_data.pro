;+
; Import a logically (2+1)-D plane of data from an EPPIC run.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA_NAME (required)
;    String name of EPPIC data quantity to read.
; LUN (default: -1)
;    Logical unit number for printing informational messages.
; ROTATE (default: 0)
;    Integer multiple of 90 degrees by which to rotate the transformed
;    array (with optional transpose). See the man page for
;    IDL's rotate() for more information.
; DATA_ISFT (default: unset)
;    Boolean keyword indicating whether or not the target data is
;    EPPIC Fourier-transformed output.
;-
function import_plane_data, data_name, $
                            lun=lun, $
                            rotate=rotate, $
                            data_isft=data_isft, $
                            _EXTRA=ex

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(rotate) eq 0 then rotate = 0

  ;;==Read data at each time step
  f_out = read_ph5_plane(data_name, $
                         lun = lun, $
                         data_isft = data_isft, $
                         _EXTRA = ex)

  ;;==Rotate data, if requested
  if ~keyword_set(data_isft) then begin
     if rotate gt 0 then begin
        fsize = size(f_out)
        if rotate mod 2 then begin
           tmp = f_out
           f_out = make_array(fsize[2],fsize[1],fsize[3],type=fsize[4],/nozero)
           for it=0,fsize[3]-1 do f_out[*,*,it] = rotate(tmp[*,*,it],rotate)
        endif $
        else for it=0,fsize[3]-1 do $
           f_out[*,*,it] = rotate(f_out[*,*,it],rotate)
     endif
  endif

  return, f_out
end
