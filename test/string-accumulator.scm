(import
  (chicken base)
  (chicken platform)
  (scheme)
  (srfi-158))
(define (eof-object) #!eof)
(define my-accumulator (string-accumulator))

; Add characters to the accumulator
(my-accumulator #\H)
(my-accumulator #\e)
(my-accumulator #\l)
(my-accumulator #\l)
(my-accumulator #\o)

; Retrieve the final string by passing an end-of-file object
(display (my-accumulator (eof-object)))
(newline)
; Output: Hello

