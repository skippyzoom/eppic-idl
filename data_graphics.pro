;+
; Make graphics from data array.
;
; This routine calls graphics routines to produce frames
; or movies of input data. It produces frames if the user
; supplies frame_name and it produces movies if the user
; supplies movie_name.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FDATA (required)
;    Either a (2+1)-D array from which to make frames,
;    a (1+1)-D array from which to make plots, or a 1-D
;    array of x-axis points for making plots.
; XDATA (optional)
;    Either a 1-D array of x-axis points for making images
;    or a (1+1)-D array from which to make plots when arg1
;    is a 1-D array of x-axis points.
; YDATA (optional)
;    A 1-D array of y-axis points for making images.
; DATA_NAME ()
; TIME (default: see below)
;    The struct or dictionary containing time-step information
;    (e.g., time indices). Typically, the top-level routine or
;    script generates this data structure. If the user does not
;    pass an appropriate data structure, this routine will create
;    a dictionary with the single member 'index' containing the
;    data indgen(nt), where nt is the number of time steps in
;    fdata.
; FRAME_NAME (optional)
;    The base name of plot or image frames to produced. This 
;    routine will prefix FRAME_PATH and affix FRAME_INFO, the 
;    array of time indices, and FRAME_TYPE to create the full
;    file path.
; FRAME_PATH (default: './')
;    The base path in which to save image or plot frames.
; FRAME_TYPE (default: '.pdf')
;    The format in which to save image or plot frames.
; FRAME_INFO (default: '')
;    Any additional text to affix to the file name (e.g., 'test',
;    'zoom-in').
; MOVIE_NAME (optional)
;    The base name of plot or image movies to produced. This 
;    routine will prefix MOVIE_PATH and affix MOVIE_INFO, the 
;    array of time indices, and MOVIE_TYPE to create the full
;    file path.
; MOVIE_PATH (default: './')
;    The base path in which to save image or plot movies.
; MOVIE_TYPE (default: '.mp4')
;    The format in which to save image or plot movies.
; MOVIE_INFO (default: '')
;    Any additional text to affix to the file name (e.g., 'test',
;    'zoom-in').
; CONTEXT (default: 'spatial')
;    The graphics context to pass to set_graphics_kw.pro
;-
pro data_graphics, fdata,xdata,ydata, $
                   data_name, $
                   time=time, $
                   frame_name=frame_name, $
                   frame_path=frame_path, $
                   frame_type=frame_type, $
                   frame_info=frame_info, $
                   movie_name=movie_name, $
                   movie_path=movie_path, $
                   movie_type=movie_type, $
                   movie_info=movie_info, $
                   context=context

  ;;==Get dimensions of data plane
  fsize = size(fdata)
  n_dims = fsize[0]
  nx = fsize[1]
  if n_dims eq 3 then begin
     ny = fsize[2]
     nt = fsize[3]
  endif else nt = fsize[2]

  ;;==Make frames
  if n_elements(frame_name) ne 0 then begin

     ;;==Defaults and guards
     frame_name = strip_extension(frame_name)
     if n_elements(frame_path) eq 0 then frame_path = './'
     if n_elements(frame_type) eq 0 then frame_type = '.pdf'
     if n_elements(frame_info) eq 0 then frame_info = ''
     if n_elements(time) eq 0 then time = dictionary()
     if ~isa(time,'dictionary') then time = dictionary(time)
     if ~time.haskey('index') then time['index'] = indgen(nt)
     if n_elements(context) eq 0 then context = 'spatial'

     ;;==Declare an array of filenames
     filename = expand_path(frame_path)+path_sep()+ $
                frame_name+frame_info+'-'+time.index+frame_type

     ;;==Set up graphics preferences
     kw = set_graphics_kw(data_name,fdata, $
                          context = context)
     if time.haskey('stamp') then begin
        text_pos = [0.05,0.85]
        text_string = time.stamp
        text_format = 'k'
     endif

     ;;==Create and save an image
     data_frame, fdata,xdata,ydata, $
                 filename = filename, $
                 multi_page = 0B, $
                 image_kw = kw.image, $
                 colorbar_kw = kw.colorbar, $
                 text_pos = text_pos, $
                 text_string = text_string, $
                 text_format = text_format, $
                 text_kw = kw.text
  endif

  ;;==Make a movie
  if n_elements(movie_name) ne 0 then begin

     ;;==Defaults and guards
     movie_name = strip_extension(movie_name)
     if n_elements(movie_path) eq 0 then movie_path = './'
     if n_elements(movie_type) eq 0 then movie_type = '.pdf'
     if n_elements(movie_info) eq 0 then movie_info = ''
     if n_elements(time) eq 0 then time = dictionary()
     if ~isa(time,'dictionary') then time = dictionary(time)
     if ~time.haskey('index') then time['index'] = indgen(nt)
     if n_elements(context) eq 0 then context = 'spatial'

     ;;==Declare the movie file path and name
     filename = expand_path(movie_path)+path_sep()+ $
                movie_name+movie_info+movie_type

     ;;==Set up graphics preferences
     kw = set_graphics_kw(data_name,fdata, $
                          context = context)
     if time.haskey('stamp') then begin
        text_pos = [0.05,0.85]
        text_string = time.stamp
        text_format = 'k'
     endif

     ;;==Create and save a movie
     data_movie, fdata,xdata,ydata, $
                 filename = filename, $
                 image_kw = kw.image, $
                 colorbar_kw = kw.colorbar, $
                 text_pos = text_pos, $
                 text_string = text_string, $
                 text_format = text_format, $
                 text_kw = kw.text
  endif

end
