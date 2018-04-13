;+
; Script to load simulation parameters and read moments files.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (default: './')
;    Path in which to search for files used to compute nt_max.
;-
if n_elements(path) eq 0 then path = './'
params = set_eppic_params(path=path)
nt_max = calc_timesteps(path=path)
params['nt_max'] = nt_max
moments = read_moments(path=path)
