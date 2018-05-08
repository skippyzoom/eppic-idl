;+
; Invert an EPPIC FT array to produce the equivalent coordinate-space
; array.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; ARRFT (required)
;    The EPPIC FT array to invert.
; LUN (default: -1)
;    Logical unit number for printing informational messages.
; ROTATE
;    Integer multiple of 90 degrees by which to rotate the transformed
;    array (with optional transpose). See the man page for
;    IDL's rotate() for more information.
;-
function arr_from_arrft, arrft, $
                         lun=lun, $
                         rotate=rotate

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(rotate) eq 0 then rotate = 0

  ;;==Create the data array based on FT array dimensions
  arr = make_array(size(arrft,/dim),type=4,/nozero)

  ;;==Invert the FT array
  ftsize = size(arrft)  
  case ftsize[0] of
     1: for it=0,ftsize[ftsize[0]]-1 do $
        arr[it] = fft(arrft[it],/inverse)
     2: for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,it] = fft(arrft[*,it],/inverse)
     3: for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,*,it] = fft(arrft[*,*,it],/inverse)
     4: for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,*,*,it] = fft(arrft[*,*,*,it],/inverse)
     5: for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,*,*,*,it] = fft(arrft[*,*,*,*,it],/inverse)
     6: for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,*,*,*,*,it] = fft(arrft[*,*,*,*,*,it],/inverse)
     7: for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,*,*,*,*,*,it] = fft(arrft[*,*,*,*,*,*,it],/inverse)
     8: for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,*,*,*,*,*,*,it] = fft(arrft[*,*,*,*,*,*,*,it],/inverse)
     else: begin
        printf, lun,"[ARR_FROM_ARRFT] Input array may have 1 to 8 dimensions."
        printf, lun,"                 Could not calculate transform."
        arr = !NULL
     end
  endcase

  ;;==Rotate the data array, if requested
  if n_elements(arr) ne 0 then begin
     if rotate ne 0 then begin
        fsize = size(arr)
        if rotate mod 2 then begin
           tmp = arr
           arr = make_array(fsize[2],fsize[1],fsize[3],type=fsize[4],/nozero)
           for it=0,fsize[3]-1 do arr[*,*,it] = rotate(tmp[*,*,it],rotate)
        endif $
        else for it=0,fsize[3]-1 do $
           arr[*,*,it] = rotate(arr[*,*,it],rotate)
     endif
  endif

  return, arr
end

