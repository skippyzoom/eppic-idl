;+
; A simple routine to open an HDF file, read the requested data,
; and close the file. This function will first check if the data
; set exists and exit gracefully if it doesn't.
;-
function get_h5_data, filename,dataname

  available = string_exists(tag_names(h5_parse(filename)),dataname,/fold_case)
  if available then begin
     fileID = h5f_open(filename)
     dataID = h5d_open(fileID,dataname)
     data = h5d_read(dataID)
     h5d_close, dataID
     h5f_close, fileID
     return, data
  endif else return, !NULL

end
