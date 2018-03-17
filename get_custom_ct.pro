;+
; Stores custom color tables and provides an RGB struct for graphics.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; CT_KEY (required)
;    The preassigned number or string corresponding to the desired table.
; LIST (default: unset)
;    Return a list of available tables.
; VERBOSE (default: unset)
;    Echo runtime messages.
;-
function get_custom_ct, ct_key,list=list,verbose=verbose

  ;;==Check value of table key
  if n_elements(ct_key) eq 0 then list = 1B $
  else begin
     if isa(ct_key,/number) then begin
        case fix(ct_key) of
           0: key = 'gwr_k'
           1: key = 'bwr_k'
           2: key = 'krgbk'
           3: key = 'krgbw'
           else: begin
              print, "[GET_CUSTOM_CT] Did not recognize key"
              list = 1B
           end
        endcase
     endif else key = ct_key
  endelse

  ;;==Build the list of available tables
  tables = dictionary()
  ;;  0: green-white-red + black at bottom
  tables['gwr_k'] = dictionary('i', [0,  1,128,255], $
                               'r', [0,  0,255,255], $
                               'g', [0,255,255,  0], $
                               'b', [0,  0,255,  0])
  ;;  1: blue-white-red + black at bottom
  tables['bwr_k'] = dictionary('i', [0,  1,128,255], $
                               'r', [0,  0,255,255], $
                               'g', [0,  0,255,  0], $
                               'b', [0,255,255,  0])
  ;;  2: black-red-green-blue-black
  tables['krgbk'] = dictionary('i', [0, 64,128,192,255], $
                               'r', [0,  0,  0,255,  0], $
                               'g', [0,  0,255,  0,  0], $
                               'b', [0,255,  0,  0,  0])
  ;;  3: black-red-green-blue-white
  tables['krgbw'] = dictionary('i', [0, 64,128,192,255], $
                               'r', [0,  0,  0,255,255], $
                               'g', [0,  0,255,  0,255], $
                               'b', [0,255,  0,  0,255])

  ;;==Return the available tables
  if keyword_set(list) then begin
     if keyword_set(verbose) then begin
        print, "[GET_CUSTOM_CT] Available tables:"
        print, "                0 'gwr_k': green-white-red + black at bottom"
        print, "                1 'bwr_k': blue-white-red + black at bottom"
        print, "                2 'krgbk': black-red-green-blue-black"
        print, "                3 'krgbw': black-red-green-blue-white"
     endif
     return, tables.keys()
  endif $
  else begin
     ;;==Fill in the color-table dictionary
     ct = dictionary(['r','g','b'])
     ct.r = interpol(tables[key].r, tables[key].i, findgen(256))
     ct.g = interpol(tables[key].g, tables[key].i, findgen(256))
     ct.b = interpol(tables[key].b, tables[key].i, findgen(256))
     
     ;;==Return the requested color table as a struct
     return, ct.tostruct()
  endelse

end
