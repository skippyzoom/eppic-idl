;+
; Build a hash containing data from multiple save files.
;
; This function builds a hash out of data arrays saved in IDL save
; files, using the save-file base names as hash keys. The IDL
; execute() command allows the use to supply the name of the data
; quantity at run time.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FILEPATH (required)
;    String or array of strings containing the full path(s) to target
;    save files.
; FILENAME (required)
;    String or array of strings containing the name(s) of target save
;    files.
; DATANAME (required)
;    String or array of strings containing the name(s) of target data
;    quantities contained in save files.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; VERBOSE (default: unset)
;    Print runtime information.
; <return>
;    Hash containing the target data quantities, keyed by their
;    respective paths.
;-
function build_multisave_hash, filepath, $
                               filename, $
                               dataname, $
                               lun=lun, $
                               verbose=verbose

  ;;==Defaults
  if n_elements(lun) eq 0 then lun = -1
  np = n_elements(filepath)
  nn = n_elements(filename)
  if nn ne np then begin
     if nn eq 1 then $
        filename = make_array(np,value=filename) $
     else $
        printf, lun, $
                "[BUILD_MULTISAVE_HASH] Please supply either a single "+$
                "string for filename or an array of strings with the same"+ $
                "number of elements as filepath ("+np+")"
  endif
  nd = n_elements(dataname)
  if nd ne np then begin
     if nd eq 1 then $
        dataname = make_array(np,value=dataname) $
     else $
        printf, lun, $
                "[BUILD_MULTISAVE_HASH] Please supply either a single "+$
                "string for dataname or an array of strings with the same"+ $
                "number of elements as filepath ("+np+")"
  endif


  ;;==Set up multi-run hash
  multi_data = hash()

  ;;==Loop over runs
  for ip=0,np-1 do begin
     fullpath = expand_path(filepath[ip])+path_sep()+filename[ip]
     s_obj = obj_new('IDL_Savefile',fullpath)
     s_obj->restore, dataname,verbose=verbose
     success = execute('array = '+dataname)
     if success then multi_data[fullpath] = array $
     else if keyword_set(verbose) then begin
        printf, lun, $
                "[BUILD_MULTISAVE_HASH] Warning: Failed to add "+ $
                dataname+" from "+path
     endif
  endfor

  return, multi_data

end
