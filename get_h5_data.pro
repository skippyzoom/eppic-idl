;+
; A simple routine to open an HDF file, read the requested data,
; and close the file. This function will first check if the data
; set exists and exit gracefully if it doesn't.
;-
function get_h5_data, filename,dataname, $
                      lun=lun, $
                      start=start, $
                      count=count

  ;;==Default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Check data availability
  available = string_exists(tag_names(h5_parse(filename)),dataname,/fold_case)
  if available then begin
     file_id = h5f_open(filename)
     data_id = h5d_open(file_id,dataname)
     if keyword_set(start) && keyword_set(count) then begin
        file_space = h5d_get_space(data_id)
        h5s_select_hyperslab, file_space,start,count,/reset
        memory_space = h5s_create_simple(count)
        data = h5d_read(data_id, $
                        file_space = file_space, $
                        memory_space = memory_space)
     endif $
     else data = h5d_read(data_id)
     h5d_close, data_id
     h5f_close, file_id
     return, data
  endif else return, !NULL

end
