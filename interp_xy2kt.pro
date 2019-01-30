;+
; Interpolate 2-D spectral data from Cartesian (kx,ky) to polar
; (k,theta).
;
; This function does not perform an FFT but is designed to work with
; an array of spectral amplitudes (i.e., a real-valued spectral
; array). Give a 2-D array of real data called 'data', the user could 
; execute fdata = abs(fft(data)) to create an appropriate input array.
; This function is not the same as a simple interpolation from
; Cartesian to polar coordinates, though it is similar.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FDATA (required)
;    Real-valued array of spectral data to interpolate.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; LAMBDA (default: 3.0)
;    The wavelength from which to calculate the spectral radius (i.e.,
;    wavenumber), k, according to k=2*!pi/lambda.
; ARRAY (default: unset)
;    Set this keyword to return an array of interpolants for a single
;    value of LAMBDA, rather than a dictionary containing multiple
;    arrays. 
; THETA (default: [0,2*!pi])
;    Range of angles over which to interpolate.
; DEGREES (default: unset)
;    Set this keyword to indicate that THETA is in degrees. This
;    function will convert THETA to radians before continuing.
; DX (default: 1.0)
;    X-dimension cell width in real space.
; DY (default: 1.0)
;    Y-dimension cell width in real space.
; <return> (dictionary or float)
;    A dictionary of structures, keyed by wavelength, each containing
;    an array of interpolated theta values, called t_interp, and an
;    array of interpolants. The t_interp array will always be 1D but
;    its size will vary with wavenumber. The f_interp array will be 1D
;    if FDATA does not contain a third (i.e., time or frequency)
;    dimension, or 2D if it does. If there is an error, this function
;    will return !NULL.
;-
function interp_xy2kt, fdata, $
                       lun=lun, $
                       lambda=lambda, $
                       array=array, $
                       theta=theta, $
                       degrees=degrees, $
                       dx=dx, $
                       dy=dy

  ;;==Get dimensions of input array
  fsize = size(fdata)
  ndims = fsize[0]
  nkx = fsize[1]
  nky = fsize[2]

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(lambda) eq 0 then lambda = 3.0
  if n_elements(theta) eq 0 then theta = [0,2*!pi]
  if n_elements(dx) eq 0 then dx = 1.0
  if n_elements(dy) eq 0 then dy = 1.0
  if keyword_set(array) and n_elements(lambda) gt 1 then begin
     str_lam = string(lambda[0],format='(f5.1)')
     str_lam = strcompress(str_lam,/remove_all)
     printf, lun,"[INTERP_XY2KT] Warning: Cannot return multiple values of"
     printf, lun,"               lambda when /array is set. I'm returning"
     printf, lun,"               just the interpolated array for the first"
     printf, lun,"               value of lambda ("+str_lam+")."
  endif

  ;;==Check dimensions
  proceed = 0B
  case ndims of 
     2: begin
        nt = 1
        proceed = 1B
     end
     3: begin
        nt = fsize[3]
        proceed = 1B
     end
     else: printf, lun,"[INTERP_XY2KT] Input array may be 2-D or (2+1)-D."
  endcase

  if proceed then begin
     ;;==Convert theta to radians, if necessary
     if keyword_set(degrees) and ~keyword_set(radians) then $
        theta *= !dtor

     ;;==Set up spectral x- and y-axis vectors for reference
     xdata = 2*!pi*fftfreq(nkx,dx)
     xdata = shift(xdata,nkx/2)
     ydata = 2*!pi*fftfreq(nky,dy)
     ydata = shift(ydata,nky/2)

     ;;==Interpolate to polar coordinates
     nl = n_elements(lambda)
     if ~keyword_set(array) then xy2kt = hash()
     for il=0,nl-1 do begin
        l_val = lambda[il]
        k_val = 2*!pi/l_val
        kx_min = xdata[nkx/2+1]
        ky_min = ydata[nky/2+1]
        t_size = 8*long(k_val/min([kx_min,ky_min]))
        t_interp = theta[0] + $
                   (theta[1]-theta[0])*dindgen(t_size)/t_size
        x_interp = cos(t_interp)*k_val/kx_min + nkx/2
        y_interp = sin(t_interp)*k_val/ky_min + nky/2
        f_interp = fltarr(t_size,nt)
        for it=0,nt-1 do $
           f_interp[*,it] = interpolate(fdata[*,*,it],x_interp,y_interp)
        if keyword_set(array) then return, f_interp
        xy2kt[l_val] = {f_interp:f_interp, t_interp:t_interp}
     endfor

     return, xy2kt
  endif else $
     return, !NULL

end
