;+
; Define the top-level directory that contains data for simulation
; runs on a given machine, if one exists.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; <return> (string)
;    Full path to the data directory, or './' (current local
;    directory) if no match to a known machine.
;-
function get_base_dir

  ;;==Query the system
  spawn, 'hostname -d',host

  ;;==Set the default directory to here
  base = './'

  ;;==Check for a host match
  case 1 of
     ;;--Boston University Shared Computing Cluster
     strcmp(host,'scc',3,/fold_case): base = '/projectnb/eregion/may/Stampede_runs'
     ;;--Texas Advanced Computing Center Stampede/Stampede2
     strcmp(host,'stampede',8,/fold_case): base = '/scratch/02994/may'
     ;;--University of New Hampshire Blackstar
     strcmp(host,'sr.unh.edu',10,/fold_case): base = '/net/home/sttg/myoung/BV_hybrid/data'
     ;;--None of the above
     else: print, "[GET_BASE_DIR] Found no match. Using './'"
  endcase

  ;;==Return the full path
  return, base
end
