;+
; Extracts the time step counter from a 
; parallel HDF file created by EPPIC.
; Assumes the file names have been trimmed
; of any trailing path. If file is an array,
; this routine will return an array. The 
; EPPIC output routines guarantees that all
; file names will have the same width 
; (see output.cc)
;-
function get_ph5timestep, file

     extDot = strpos(file[0],'.',/reverse_search)
     firstNum = strpos(file[0],'0')
     numLen = extDot-firstNum
     timestep = long(strmid(file,firstNum,numLen))

  return, timestep
end
