;+
; Reads an EPPIC input file into a dictionary. This function is
; intended to replace the @ppic3d.i/@eppic.i paradigm.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (default: './')
;    Path in which to search for parameter file.
; FILENAME (default: 'ppic3d.i')
;    Base name of parameter file to read.
; COMMENT (default: ';')
;    Character that signifies a comment in the parameter file.
; VERBOSE (default: unset)
;    Print runtime informational messages.
; <return> (dictionary)
;    Simulation parameters from the EPPIC input file.
;-
function read_parameter_file, path, $
                              filename=filename, $
                              comment=comment, $
                              verbose=verbose

  ;;==Defaults and guards
  if n_elements(filename) eq 0 then filename = 'ppic3d.i'
  if n_elements(comment) eq 0 then comment = ';'

  ;;==Check existence of parameter file
  filepath = expand_path(path)+path_sep()+filename
  if ~file_test(filepath) then begin
     if keyword_set(verbose) then $
        print, "[READ_PARAMETER_FILE] Could not find ",filepath
     default_names = ['ppic3d.i','eppic.i']
     check_default = where(file_test(path+path_sep()+default_names),count)
     if count ne 0 then begin
        filepath = expand_path(path)+path_sep()+ $
                   default_names[min(check_default)]
        if keyword_set(verbose) then $
           print, "[READ_PARAMETER_FILE] Using parameter file ",filepath
     endif else begin
        if keyword_set(verbose) then $
           print, "[READ_PARAMETER_FILE] Cannot create parameter dictionary"
        return, !NULL
     endelse
  endif

  ;;==Read parameters from file
  openr, rlun,filepath,/get_lun
  line = ''
  params = dictionary()
  for il=0,file_lines(filepath)-1 do begin
     readf, rlun,line
     if ~strcmp(strmid(line,0,1),comment) then begin
        eq_pos = strpos(line,'=')
        if eq_pos ge 0 then begin
           name = strcompress(strmid(line,0,eq_pos),/remove_all)
           value = strtrim(strmid(line,eq_pos+1,strlen(line)),2)
           params[name] = detect_type(value,/convert,/long,/double)
        endif
     endif
  endfor
  close, rlun
  free_lun, rlun

  return, params
end
