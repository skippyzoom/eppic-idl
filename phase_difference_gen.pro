function phase_difference_gen, f1,f2, $
                               lun=lun, $
                               quiet=quiet

  ;;==Set the default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Check for correct number of dimensions
  if size(f1,/n_dim) eq 2 && size(f2,/n_dim) eq 2 then begin

     ;;==Get array dimensions
     fsize = size(f1)
     nx = fsize[1]
     ny = fsize[2]

     ;;==Extract means
     mf1 = mean(f1)
     mf2 = mean(f2)

     ;;==Shift to zero mean
     df1 = (f1-mf1)/mf1
     df2 = (f2-mf2)/mf2

     ;;==Compute the spectral power densities
     df1_spd = rms(df1)^2
     df2_spd = rms(df2)^2

     ;;==Calculate ACFs and CCF
     f12_cc = convol_fft(f1,f2,/correlate)
     f1_acf = convol_fft(f1,f1,/auto_correlation)
     f2_acf = convol_fft(f2,f2,/auto_correlation)
     df1_acf = convol_fft(df1,df1,/auto_correlation)

     ;;==Extract values at zero lag
     r12 = f12_cc[nx/2-1,ny/2-1]
     r1 = f1_acf[nx/2-1,ny/2-1]
     r2 = f2_acf[nx/2-1,ny/2-1]

     ;;==Define alpha, for convenience
     alpha = (r12/sqrt(r1*r2))*sqrt(df1_spd*df2_spd)

     ;;==Find minimizing index
     argmin = where(df1_acf-alpha eq min(df1_acf-alpha,/nan))
     if n_elements(argmin) gt 1 then begin
        if ~keyword_set(quiet) then begin
           printf, lun,"[PHASE_DIFFERENCE_GEN] Found more than one index"
           printf, lun,"                       with minimum value"
        endif
        argmin = argmin[0]
     endif

     ;;==Return equivalent 2-D indices
     return, array_indices(fltarr(nx,ny),argmin)
  endif $
  else begin

     ;;==Let the user know of incorrect number of dimensions
     if ~keyword_set(quiet) then $
        printf, lun,"[PHASE_DIFFERENCE_GEN] Both input arrays must be 2-D"

     ;;==Return null value
     return, !NULL
  endelse

end
