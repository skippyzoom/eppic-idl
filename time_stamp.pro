;+
; Create a time stamp from systime() for use in file names
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; MODE (default: 'full')
;    String selecting the time of time stamp to output
;    'full': A version of the full output from systime,
;            modified for use in filenames.
;    'date': The date in DDMMYYYY format.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
;-
function time_stamp, mode=mode,lun=lun

  ;;==Defaults and guards
  if n_elements(mode) eq 0 then mode = 'full'
  if n_elements(lun) eq 0 then lun = -1

  ;;==Extract time and date information
  comp = strcompress(strsplit(systime(),/extract),/remove_all)
  dow = comp[0]
  mon = comp[1]
  day = string(comp[2],format='(i02)')
  time = comp[3]
  hh = strmid(time,0,2)
  mm = strmid(time,3,2)
  ss = strmid(time,6,2)
  year = comp[4]

  ;;==Construct the time stamp
  stamp = ''
  case 1B of 
     strcmp(mode,'full'): begin
        stamp = dow+'_'+mon+'_'+day+'_'+hh+mm+ss+'_'+year
     end
     strcmp(mode,'date'): begin
        stamp = day+mon+year
     end
     else: printf, lun,"[TIME_STAMP] Did not recognize mode ("+ $
                   mode+")"
  endcase
  
  return, stamp
end
