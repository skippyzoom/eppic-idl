;+
; Read column-separated text from a file
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (required)
;    Path to data file.
; PATTERN (default: ' ')
;    Pattern for strsplit.
; HEAD_LENGTH (default: 0)
;    Length of data-file header.
; <return> (float)
;    Array of data from file.
;-
function read_coltxt, path, $
                      pattern=pattern, $
                      head_length=head_length

  ;;==Set defaults
  if n_elements(pattern) eq 0 then pattern = ' '
  if n_elements(head_length) eq 0 then head_length = 0

  ;;==Get number of lines of data
  nl = file_lines(path)-head_length

  ;;==Get number of columns of data
  line = ''
  openr, rlun,path,/get_lun
  point_lun, rlun,0
  skip_lun, rlun,head_length,/lines
  readf, rlun,line
  line_data = strsplit(line,pattern,/extract)
  nc = n_elements(line_data)

  ;;==Set up data array
  data = fltarr(nl,nc)

  ;;==Read all data
  point_lun, rlun,0
  skip_lun, rlun,head_length,/lines
  il = 0L
  while ~eof(rlun) do begin
     readf, rlun,line
     line_data = strsplit(line,pattern,/extract)
     data[il++,*] = line_data
  endwhile

  ;;==Close data file
  close, rlun
  free_lun, rlun

  return, data
end
