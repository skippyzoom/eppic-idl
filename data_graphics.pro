;+
; Routine for producing frames or movies of EPPIC data from a (2+1)-D array.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; ARG1 (required)
;    Either a (2+1)-D array from which to make images,
;    a (1+1)-D array from which to make plots, or a 1-D
;    array of x-axis points for making plots.
; ARG2 (optional)
;    Either a 1-D array of x-axis points for making images
;    or a (1+1)-D array from which to make plots when arg1
;    is a 1-D array of x-axis points.
; ARG3 (optional)
;    1-D array of y-axis points for making images.
; LUN (default: -1)
;    Logical unit number for printing runtime messages.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This routine selects plot_graphics or image_graphics,
;    and the appropriate calling sequence, based on the dimensions 
;    of arg1, arg2, and arg3.
;-
pro data_graphics, arg1,arg2,arg3, $
                   lun=lun, $
                   _EXTRA=ex

  ;;==Default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Determine image/plot mode from input dimensions
  size1 = size(arg1)
  call_seq_err = 0B
  case size1[0] of
     1: begin
        size2 = size(arg2)
        if size2[0] eq 2 then begin

           ;;==Make movie from plot frames
           plot_graphics, arg1,arg2, $
                          lun=lun, $
                          _EXTRA=ex

        endif $
        else call_seq_err = 1B
     end
     2: begin

        ;;==Make movie from plot frames
        plot_graphics, arg1, $
                       lun=lun, $
                       _EXTRA=ex

     end
     3: begin
        size2 = size(arg2)
        size3 = size(arg3)
        case 1B of
           (size2[0] eq 1 and size3[0] eq 1): begin

              ;;==Make movie from image frames
              image_graphics, arg1,arg2,arg3, $
                              lun=lun, $
                              _EXTRA=ex

           end
           (size2[0] eq 0 and size3[0] eq 0): begin

              ;;==Make movie from image frames
              movdata = arg1
              image_graphics, movdata, $
                              lun=lun, $
                              _EXTRA=ex

           end
           else: call_seq_err = 1B
        endcase
     end
     else: call_seq_err = 1B
  endcase
  if call_seq_err then begin
     cr = (!d.name eq 'WIN') ? string([13B,10B]) : string(10B)
     err_msg = "[DATA_GRAPHICS] Calling sequence may be either:"+cr+ $
               "                "+ $
               "IDL> data_graphics, xdata[,ydata][,kw/prop]"+cr+ $
               "                "+ $
               "with 1-D xdata and (1+1)-D ydata for plot frames"+cr+ $
               "                "+ $
               "                   OR"+cr+ $
               "                "+ $
               "IDL> data_graphics, fdata[,xdata][,ydata][,kw/prop]"+cr+ $
               "                "+ $
               "with (2+1)-D fdata, 1-D xdata, and 1-D ydata for image frames"
     printf, lun,err_msg
  endif

end
