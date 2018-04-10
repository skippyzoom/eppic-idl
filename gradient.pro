;+
; Returns a dictionary representing the gradient of a function, f.
; Each member field contains one component of Grad[f].
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; F (required)
;    The function whose gradient to calculate
; DX[,DY,DZ] (default: 1.0 for all)
;    Differential values for computing point-wise centered finite
;    differences. The user may supply a single value for each
;    differential or may supply dx as a vector of differentials. If f
;    has more than 3 dimensions, dx must be a vector. This approach
;    provides consistency with other gradient functions, which only
;    allow the user to supply scalar differential values, while
;    providing an interface that can handle arrays as large as the
;    maximum allowed by IDL. If the user supplies separate values for
;    each, this function will return a dictionary with keys (x[,y,z]);
;    if the user supplies a vector of differentials, this function
;    will return a dictionary with keys [x1,x2,...,xN].
;-
function gradient, f, $
                   dx=dx,dy=dy,dz=dz, $
                   verbose=verbose

  ;;==Get size of input array
  fsize = size(f)

  ;;==Defaults and gaurds
  use_xyz = 0B
  case n_elements(dx) of 
     0: dx = make_array(size(f,/n_dim),value = 1.0)
     1: begin
        if n_elements(dy) eq 0 then begin
           dy = dx
           if keyword_set(verbose) then $
              print, "[GRADIENT] Set dy = dx = ",strcompress(dx,/remove_all)
        endif
        if n_elements(dz) eq 0 then begin
           dz = dx
           if keyword_set(verbose) then $
              print, "[GRADIENT] Set dz = dx = ",strcompress(dx,/remove_all)
        endif
        dq = [dx,dy,dz]
        use_xyz = 1B
     end
     else: begin
        if n_elements(dx) ne fsize[0] then begin
           dq = fltarr(size(f,/n_dim))
           dq[0:n_elements(dx)-1] = dx
           dq[n_elements(dx):*] = 1.0
           if keyword_set(verbose) then $
              print, "[GRADIENT] Set remaining entries of dq to 1.0"
        endif
     end
  endcase

  ;;==Create a dictionary
  gradf = dictionary()
  
  ;;==Set up coordinate keys
  if use_xyz then coord = ['x','y','z'] $
  else coord  = 'x'+strcompress(1+indgen(n_elements(dq)),/remove_all)

  ;;==Set up the shift vectors
  svec = make_array([2,size(f,/n_dim)],type=size(f,/type),value=0)
  svec[0,0] = -1.0
  svec[1,0] = +1.0

  ;;==Calculate the gradient
  for id=0,size(f,/n_dim)-1 do begin
     gradf[coord[id]] = (shift(f,svec[0,*])-shift(f,svec[1,*]))/(2*dq[id])
     svec[0,*] = shift(svec[0,*],1)
     svec[1,*] = shift(svec[1,*],1)
  endfor

  return, gradf
end
