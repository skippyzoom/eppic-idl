;+
; Return string time stamps and time indices
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; TIMESTEP (required)
;    Simulation timesteps in use for data analysis.
; DT (default: 1.0)
;    The simulation time-step interval.
; SCALE (default: 1.0)
;    A power of ten by which to scale the time steps.
;    The value of this parameter will also determine
;    the unit prefix to use for time stamps.
; PRECISION (default: 0)
;    Floating-point precision to use for time steps.
; WIDTH (default: '(i06)')
;    Integer width to which to pad time index, or 'auto' to compute
;    the maximum necessary width from TIMESTEP.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
;-
function time_strings, timestep, $
                       dt=dt, $
                       scale=scale, $
                       precision=precision, $
                       width=width, $
                       lun=lun

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(dt) eq 0 then dt = 1.0
  if n_elements(scale) eq 0 then scale = 1.0
  if ~(alog10(scale)-fix(alog10(scale)) eq 0) then begin
     str_scl_in = strcompress(string(scale),/remove_all)
     scale = 10^fix(alog10(scale))
     str_scl = strcompress(string(scale),/remove_all)
     printf, lun,"[TIME_STRINGS] Warning: Scale must be a power of 10."
     printf, lun,"               You entered ",str_scl_in," so I'm going"
     printf, lun,"               to use ",str_scl
  endif
  if n_elements(precision) eq 0 then precision = 0
  if ~isa(precision,/int) then begin
     precision = fix(precision)
     str_prec = strcompress(precision,/remove_all)
     printf, lun,"[TIME_STRINGS] Warning: Specified precision was not"
     printf, lun,"               an integer. Using ",str_prec
  endif

  ;;==Determine scale order of magnitude
  ud = build_units_dictionary()
  keys = ud.prefixes.keys()
  vals = ud.prefixes.values()
  unit_oom = fix(alog10(1.0/scale))
  test = keys[where(vals eq unit_oom,count)]
  if count ne 0 then unit = test[0]+"s" $
  else begin
     str_scl = strcompress(string(scale),/remove_all)
     printf, lun,"[TIME_STRINGS] Warning: Could not find an appropriate"
     printf, lun,"               unit for ",str_scl,". I'm going to use"
     printf, lun,"               the number"
     unit = "s $\times$ "+str_scl
  endelse

  ;;==Get number of time steps
  nt = n_elements(timestep)

  ;;==Convert time steps into physical units
  ts_phys = scale*dt*timestep

  ;;==Calculate width for physical time steps
  ts_oom = fix(alog10(ts_phys[nt-1]))
  str_fmt = '(f'+ $
            strcompress(ts_oom+1+precision+1,/remove_all)+ $
            '.'+strcompress(precision,/remove_all)+')'

  ;;==Convert time steps to strings in physical units
  str_time = strcompress(string(ts_phys, $
                                format=str_fmt),/remove_all)

  ;;==Create array of time stamps
  time_stamp = "t = "+str_time+" "+unit

  ;;==Calculate width for time-step indices
  if keyword_set(width) then begin
     case 1B of
        isa(width,/integer): $
           str_fmt = '(i0'+strcompress(width,/remove_all)+')'
        strcmp(width,'auto'): begin
           nt_oom = fix(alog10(timestep[nt-1]))
           str_fmt = '(i0'+strcompress(nt_oom+1,/remove_all)+')'
        end
        else: begin
           printf, lun,"[TIME_STRINGS] Could not understand width."
           printf, lun,"               Using default ( '(i06)' ) instead."
           width = '(i06)'
        end
     endcase
  endif $
  else width = '(i06)'

  ;;==Create array of indices
  time_index = strcompress(string(timestep, $
                                  format=str_fmt),/remove_all)

  return, {stamp:time_stamp, index:time_index}
end
