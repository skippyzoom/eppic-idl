;+
; I adapted this code from the web address 
; >  http://www.exelisvis.com/Company/PressRoom/Blogs/
; >  IDLDataPointDetail/TabId/902/ArtMID/2926/ArticleID/
; >  13040/Finding-the-next-power-of-two.aspx
; Credit for original code goes to Ron Kneusel
;
; I believe the ishft arguments go to 64 to cover 64-bit systems.
;
; Adapted by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; X (required)
;    The number to be raised.
; <return>
;    The smallest power of 2 not less than x.
;------------------------------------------------------------------------------
;                                   **NOTES**
; -- This function returns the smallest possible power of 2.
;    In other words, if x is a power of 2, it will return x. 
;    That is useful when the user just wants to make sure an
;    array has dimensions that are powers of 2 without knowing
;    the dimensions until runtime (e.g. when padding an array
;    before taking the FFT). 
;-
function next_power2, x
  compile_opt idl2, logical_predicate

  n = x-1
  n = ishft(n,-1) or n
  n = ishft(n,-2) or n
  n = ishft(n,-4) or n
  n = ishft(n,-8) or n
  n = ishft(n,-16) or n
  n = ishft(n,-32) or n
  n = ishft(n,-64) or n

  return, ++n
end
