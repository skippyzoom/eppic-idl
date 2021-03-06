;+
; Attempts to determine how many time steps are available for a
; simulation run. Designed to handle typical PPIC3D or EPPIC runs.
;
; The CASE structure is designed to test the most common cases first,
; for the sake of efficiency, but the speed-up may be negligible.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (default: './')
;    Path in which to search for files used to compute nt_max.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; VERBOSE (default: unset)
;    Print runtime information.
; <return> (long int)
;    Maximum number of available time steps.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- The parallel HDF method assumes all *.h5 files are
;    in the parallel directory. The user must be careful
;    when only transfering a subset of files from another
;    system (e.g. Stampede).
;-
function calc_timesteps, path=path, $
                         lun=lun, $
                         verbose=verbose
  
  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Set default path
  if n_elements(path) eq 0 then path = './'

  ;;==Read in parameters
  params = set_eppic_params(path=path)

  ;;==Check typical cases for a way to compute nt_max
  nt_max = 0L
  case 1 of
     file_test(expand_path(path+path_sep()+'moments1.out')): begin
        nt_max = file_lines(expand_path(path+path_sep()+'moments1.out'))-1
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Computed max time steps from moments1.out"
     end
     file_test(expand_path(path+path_sep()+'moments0.out')): begin
        nt_max = file_lines(expand_path(path+path_sep()+'moments0.out'))-1
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Computed max time steps from moments0.out"
     end
     file_test(expand_path(path+path_sep()+'domain000/moments1.out')): begin
        nt_max = file_lines(expand_path(path+path_sep()+ $
                                        'domain000/moments1.out'))-1
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Computed max time steps from "+ $
                   "domain000/moments1.out"
     end
     file_test(expand_path(path+path_sep()+'domain000/moments0.out')): begin
        nt_max = file_lines(expand_path(path+path_sep()+ $
                                        'domain000/moments0.out'))-1
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Computed max time steps from " +$
                   "domain000/moments0.out"
     end
     file_test(expand_path(path+path_sep()+'parallel'),/directory): begin
        !NULL = file_search(expand_path(path+path_sep()+ $
                                        'parallel/*.h5'),count=count)
        nt_max = count
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Computed max time steps from parallel/*.h5"
     end
     file_test(expand_path(path+path_sep()+'den1.bin')): begin
        test_file = expand_path(path+path_sep()+'domain000')
        if file_test(test_file,/directory) then $
           bp = expand_path(path+path_sep()+'domain*/') $
        else bp = expand_path(path+path_sep()+'./')
        nt_max = timesteps(expand_path(path+path_sep()+'den1.bin'), $
                           params.sizepertime,params.nsubdomains,basepath=bp)
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Computed max time steps from den1.bin"
     end
     file_test(expand_path(path+path_sep()+'phi.bin')): begin
        test_file = expand_path(path+path_sep()+'domain000')
        if file_test(test_file,/directory) then $
           bp = expand_path(path+path_sep()+'domain*/') $
        else bp = expand_path(path+path_sep()+'./')
        nt_max = timesteps(expand_path(path+path_sep()+'phi.bin'), $
                           params.sizepertime,params.nsubdomains,basepath=bp)
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Computed max time steps from phi.bin"
     end
     file_test(expand_path(path+path_sep()+'den0.bin')): begin
        test_file = expand_path(path+path_sep()+'domain000')
        if file_test(test_file,/directory) then $
           bp = expand_path(path+path_sep()+'domain*/') $
        else bp = expand_path(path+path_sep()+'./')
        nt_max = timesteps(expand_path(path+path_sep()+'den0.bin'), $
                           params.sizepertime,params.nsubdomains,basepath=bp)
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Computed max time steps from 'den0.bin'"
     end
     else: begin
        if keyword_set(verbose) then $
           printf, lun, $
                   "[CALC_TIMESTEPS] Could not compute max time steps"
     end
  endcase

  return, nt_max

end
