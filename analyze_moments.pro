;+
; Script for reading moments files and plotting derived quantities
;-

;;==Set default paths, if necessary
if n_elements(path) eq 0 then path = './'

;;==Read simulation parameters, if necessary
if n_elements(params) eq 0 then $
   params = set_eppic_params(path=path)

;;==Read moments files
moments = read_moments(path=path)

;;==Create plots
plot_moments, moments, $
              params = params, $
              save_path = path+path_sep()+'frames'
