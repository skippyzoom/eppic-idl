;+
; Read a single HDF5 file.
;
; This function first checks that an HDF5 file contains the requested
; data set. If the data is available, this function opens the file,
; reads the requested data (or a subset thereof), and closes the
; file. If the data is not available, this function exits
; gracefully.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FILENAME (required)
; DATANAME (required)
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
; START (default: none)
;    Array of starting indices for selecting a data subset.
; COUNT (default: none)
;    Array of lengths of data subset in each dimension.
; <return>
;    The requested data array.
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
