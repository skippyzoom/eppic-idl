;+
; Get time step of a parallel HDF5 EPPIC output file.
;
; This function extracts the time step counter from a parallel HDF
; file created by EPPIC. Assumes the file names have been trimmed of
; any trailing path. If FILENAME is an array, this routine will return
; an array. The EPPIC output routines guarantees that all file names
; have the same width and do not contain numbers other than the time
; step value (see output.cc).
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FILENAME (required)
;    Name of the file to check.
; <return> (long int)
;    The time step at which EPPIC wrote the file.
;-
function get_ph5timestep, filename

  ;;==Determine location in FILENAME of the extension
  ext_dot = strpos(filename[0],'.',/reverse_search)

  ;;==Determine location in FILENAME of the first number
  first_num = strpos(filename[0],'0')

  ;;==Calculate the length of the time step value
  num_len = ext_dot-first_num

  ;;==Remove the time step value and convert to a long int
  timestep = long(strmid(filename,first_num,num_len))

  return, timestep
end
