; Read an EPPIC input file into a dictionary. This function
; is intended to replace the @ppic3d.i/@eppic.i paradigm.
;-
function read_parameter_file, path, $
                              name=name, $
                              comment=comment, $
                              verbose=verbose

  ;;==Defaults and guards
  if n_elements(name) eq 0 then name = 'ppic3d.i'
  if n_elements(comment) eq 0 then comment = ';'

  ;;==Check existence of parameter file
  filename = expand_path(path+path_sep()+name)
  if ~file_test(filename) then begin
     if keyword_set(verbose) then $
        print, "[READ_PARAMETER_FILE] Could not find ",filename
     default_names = ['ppic3d.i','eppic.i']
     check_default = where(file_test(path+path_sep()+default_names),count)
     if count ne 0 then begin
        filename = expand_path(path+path_sep()+ $
                               default_names[min(check_default)])
        if keyword_set(verbose) then $
           print, "[READ_PARAMETER_FILE] Using parameter file ",filename
     endif else begin
        if keyword_set(verbose) then $
           print, "[READ_PARAMETER_FILE] Cannot create parameter dictionary"
        return, !NULL
     endelse
  endif

  ;;==Read parameters from file
  openr, rlun,filename,/get_lun
  line = ''
  params = dictionary()
  for il=0,file_lines(filename)-1 do begin
     readf, rlun,line
     if ~strcmp(strmid(line,0,1),comment) then begin
        eq_pos = strpos(line,'=')
        if eq_pos ge 0 then begin
           name = strcompress(strmid(line,0,eq_pos),/remove_all)
           value = strtrim(strmid(line,eq_pos+1,strlen(line)),2)
           params[name] = detect_type(value,/convert)
        endif
     endif
  endfor
  close, rlun
  free_lun, rlun

  return, params
end
