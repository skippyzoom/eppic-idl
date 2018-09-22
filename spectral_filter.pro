;+
; Spectrally filters the input data by suppressing the real part
; wherever it falls below a threshold value. 
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; DATA (required)
;    The data to filter.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; THRESHOLD (default: 1e-6)
;    The threshold value below which to suppress data real-part
;    amplitude (in other words, the noise floor). 
; NOISE (default: 0.0)
;    Value to which to set sub-threshold data.
; RELATIVE (default: unset)
;    Indicates that the user has defined THRESHOLD relative to the
;    maximum real amplitude.
; <return>
;    A filtered array of the same type as DATA
;-
function spectral_filter, data, $
                          lun=lun, $
                          threshold=threshold, $
                          noise=noise, $
                          relative=relative

  ;;==Set defaults
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(threshold) eq 0 then threshold = 1e-6
  if n_elements(noise) eq 0 then noise = 0.0

  ;;==Get dimensions of input data
  dsize = size(data)
  nx = dsize[1]
  ny = dsize[2]
  nt = dsize[dsize[0]]

  ;;==Check for (2+1)-D or (3+1)-D data
  case dsize[0] of 
     3: begin

        ;;==Set up FFT array
        fftdata = complexarr(nx,ny,nt)

        ;;==Calculate FFT
        for it=0,nt-1 do $
           fftdata[*,*,it] = fft(data[*,*,it])

        ;;==Check for relative threshold
        if keyword_set(relative) then threshold *= max(real_part(fftdata))

        ;;==Determine where spectral data falls below threshold
        ind = where(abs(real_part(fftdata)) lt threshold)

        ;;==Set sub-threshold data to noise value
        fftdata[ind] = noise

        ;;==Set up return array
        retdata = data*0.0

        ;;==Store inverse FFT of filtered data in return array
        for it=0,nt-1 do $
           retdata[*,*,it] = fft(fftdata[*,*,it],/inverse)
     end
     4: begin

        ;;==Set up FFT array
        fftdata = complexarr(nx,ny,nt)

        ;;==Calculate FFT
        for it=0,nt-1 do $
           fftdata[*,*,*,it] = fft(data[*,*,*,it])

        ;;==Check for relative threshold
        if keyword_set(relative) then threshold *= max(real_part(fftdata))

        ;;==Determine where spectral data falls below threshold
        ind = where(abs(real_part(fftdata)) lt threshold)

        ;;==Set sub-threshold data to noise value
        fftdata[ind] = noise

        ;;==Set up return array
        retdata = data*0.0

        ;;==Store inverse FFT of filtered data in return array
        for it=0,nt-1 do $
           retdata[*,*,*,it] = fft(fftdata[*,*,*,it],/inverse)
     end
     else: begin
        printf, lun,"[SPECTRAL_FILTER] Input data must be (2+1)-D or (3+1)-D."
     end
  endcase 

  return, retdata
end
