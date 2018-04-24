;+
; A simple routine to open an HDF file, read the requested data,
; and close the file. This function will first check if the data
; set exists and exit gracefully if it doesn't.
;-
function get_h5_data, filename,dataname,axes=axes

  available = string_exists(tag_names(h5_parse(filename)),dataname,/fold_case)
  if available then begin
     file_id = h5f_open(filename)
     data_id = h5d_open(file_id,dataname)
     ;; if keyword_set(axes) then begin
     ;;    case 1B of 
     ;;       strcmp(axes,'xy') || strcmp(axes,'yx'): begin              
     ;;       end
     ;;       strcmp(axes,'xz') || strcmp(axes,'zx'): begin
     ;;       end
     ;;       strcmp(axes,'yz') || strcmp(axes,'zy'): begin
     ;;       end
     ;;    endcase
     ;; endif $
     ;; else data = h5d_read(data_id)
     data = h5d_read(data_id)
     h5d_close, data_id
     h5f_close, file_id
     return, data
  endif else return, !NULL

end
