;+
; Return zero.
;
; This function returns a type-appropriate "zero" value for numerical
; or string types (e.g. 0.0 for float or ' ' for string) and !NULL for
; all other types.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; TYPE (required)
;    Numerical IDL variable type (e.g., 4 for single-precision
;    floating point type).
; <return> (type of TYPE)
;    Numerical zero, empty string, or !NULL.
;-

function get_zero, type

  ;;==Select the IDL type
  case type of
     1: zero = byte(0)
     2: zero = fix(0)
     3: zero = long(0)
     4: zero = float(0)
     5: zero = double(0)
     6: zero = complex(0)
     7: zero = ' '
     9: zero = dcomplex(0)
     12: zero = uint(0)
     13: zero = ulong(0)
     14: zero = long64(0)
     15: zero = ulong64(0)
     else: zero = !NULL
  endcase

  ;;==Return "zero"
  return, zero

end
