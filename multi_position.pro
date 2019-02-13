;+
; Calculate an array of plot positions for graphics
; routines, given the total number of requested plots.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; NP (required) 
;    Number of plots, either a scalar or an array of [ncols,nrows].
; EDGES (default: [0.0,0.0,1.0,1.0]) 
;    Either an 4-element array of the form [left,bottom,right,top]
;    that specifies the global graphics edges, or a [nplots,2] array 
;    that specifies the left and bottom edges for each panel. 
; BUFFERS (default: [0.0,0.0]) 
;    A 2-element array of the form [width,height] That specifies the
;    buffers between adjacent panels. The function ignores this
;    keyword when WIDTH and HEIGHT are set. 
; WIDTH (default: unset) 
;    Width of individual panels when edges is [nplots,2].
; HEIGHT (default: unset) 
;    Height of individual panels when edges is [nplots,2].
; <return> (float array)
;    Normalized positions for NP graphics frames.
;-
function multi_position, np, $
                         edges=edges,buffers=buffers, $
                         width=width,height=height

  ;;==Defaults and guards
  case n_elements(np) of
     1: begin
        nc = fix(sqrt(np))+((sqrt(np) mod 1) gt 0)
        nr = nc
     end
     2: begin
        nc = np[0]
        nr = np[1]
        np = nr*nc
     end
     else: message, "np may be a scalar or [ncols,nrows]" 
  endcase
  if n_elements(edges) eq 0 then edges = [0.0,0.0,1.0,1.0]
  if n_elements(buffers) eq 0 then buffers = [0.0,0.0]

  ;;==Declare array
  position = fltarr(4,np)

  ;;==Check that width and height are set/unset consistently
  if keyword_set(width) and ~keyword_set(height) then $
     message, "When using WIDTH, you must also provide HEIGHT."
  if keyword_set(height) and ~keyword_set(width) then $
     message, "When using HEIGHT, you must also provide WIDTH."

  if keyword_set(width) and keyword_set(height) then begin

     ;;==Check edges array
     if array_equal(size(edges,/dim),[np,2]) eq 0 then begin
        errmsg = "When using WIDTH and HEIGHT keywords,"
        errmsg += "  edges must be a [nplots,2] array that specifies"
        errmsg += "  the left and bottom edge of each plot."
        message, errmsg
     endif

     ;;==Fill position array
     for ip=0,np-1 do begin
        ic = ip mod nc
        ir = ip / nc
        x1 = edges[ip,0]
        x2 = x1+width
        y1 = edges[ip,1]
        y2 = y1+height
        position[*,ip] = [x1,y1,x2,y2]
     endfor

  endif else begin

     ;;==Set up geometry
     full_width = edges[2]-edges[0]
     full_height = edges[3]-edges[1]
     plot_width = float(full_width-(nc-1)*buffers[0])/nc
     plot_height = float(full_height-(nr-1)*buffers[1])/nr

     ;;==Fill position array
     for ip=0,np-1 do begin
        ic = ip mod nc
        ir = ip / nc
        x1 = edges[0]+ic*(buffers[0]+plot_width)
        x2 = x1+plot_width
        y1 = edges[3]-(ir+1)*plot_height-ir*buffers[1]
        y2 = y1+plot_height
        position[*,ip] = [x1,y1,x2,y2]
     endfor

  endelse

  return, position
end
