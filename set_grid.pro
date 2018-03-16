;+
; Set quantities related to the simulation grid.
;
; The purpose of the grid struct is that other routines can
; build subsets of the coordinates without running into 
; recursion problems. It also allows routines to pass around
; the struct instead of calling set_eppic_params.pro
;
; Parallel HDF routines swap the X and Z dimensions in 
; output.cc, so this routine will undo that swap if it 
; detects that EPPIC used parallel HDF output.
;-

function set_grid, path=path
  
  if n_elements(path) eq 0 then path = './'

  params = set_eppic_params(path=path)
  if n_elements(params) ne 0 then begin
     if params.hdf_output_arrays eq 2 then begin
        case params.ndim_space of
           2: begin
              nxg = params.nx*params.nsubdomains/params.nout_avg
              x = params.dx*params.nout_avg*findgen(nxg)
              nyg = params.ny/params.nout_avg
              y = params.dy*params.nout_avg*findgen(nyg)
              nzg = 1
              z = findgen(nzg)
              sizepertime = long64(nxg)*long64(nyg)*long64(nzg)
              nout_avg = params.nout_avg
              nsubdomains = params.nsubdomains
           end
           3: begin
              nzg = params.nz/params.nout_avg
              z = params.dz*params.nout_avg*findgen(nzg)
              nyg = params.ny/params.nout_avg
              y = params.dy*params.nout_avg*findgen(nyg)
              nxg = params.nx*params.nsubdomains/params.nout_avg
              x = params.dx*params.nout_avg*findgen(nxg)
              sizepertime = long64(nxg)*long64(nyg)*long64(nzg)
              nout_avg = params.nout_avg
              nsubdomains = params.nsubdomains
           end
        endcase
     endif else begin
        nxg = params.nx*params.nsubdomains/params.nout_avg
        x = params.dx*params.nout_avg*findgen(nxg)
        nyg = params.ny/params.nout_avg
        y = params.dy*params.nout_avg*findgen(nyg)
        nzg = 1
        z = findgen(nzg)
        if params.ndim_space eq 3 then begin
           nzg = params.nz/params.nout_avg
           z = params.dz*params.nout_avg*findgen(nzg)
        endif
        sizepertime = long64(nxg/params.nsubdomains)*long64(nyg)*long64(nzg)
        nout_avg = params.nout_avg
        nsubdomains = params.nsubdomains
     endelse

     grid = {x:x, y:y, z:z, $
             nx:nxg, ny:nyg, nz:nzg, $
             dx:params.dx, dy:params.dy, dz:params.dz, $
             sizepertime:sizepertime, $
             nout_avg:params.nout_avg, nsubdomains:params.nsubdomains}
     return, grid
  endif $ ;;params exists
  else print, "[SET_GRID] Could not create grid without parameter dictionary."
end
