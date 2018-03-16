function get_base_dir

  spawn, 'hostname -d',host
  base = './'
  case 1 of
     strcmp(host,'scc',3,/fold_case): base = '/projectnb/eregion/may/Stampede_runs'
     strcmp(host,'stampede',8,/fold_case): base = '/scratch/02994/may'
     else: print, "GET_BASE_DIR: Found no match. Using './'"
  endcase

  return, base
end
