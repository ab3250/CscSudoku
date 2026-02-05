;;;; get-cell-contents
;;;; get-box-cell-list row col
(import
  (chicken base)
  (chicken platform)
  (scheme)
  (scheme)
  (srfi 196)
  (srfi 158)
  (srfi 130)
  (srfi 69)
  (medea)
  (chicken foreign))

(load "lib/175.scm")


(define (displayln x)
  (display x)
  (newline))

  (define (identity x)
  x)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (eof-object) #!eof)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (between-inclusive x min max)
    (and (>= x min)(<= x max)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (print-grid grid)
    (define for-nest-func (lambda (row end func)
      (let loop ((index row))
        (if (> index end) #t
          (begin
            (func index)
            (loop (+ index 1)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (newline)
    (for-nest-func 0 8 (lambda(row)
      (for-nest-func 0 8 (lambda(col)
        (display (string-ref grid (row-col->cell row col)))))
        (newline))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (no-zeros-left? grid)
    (= 0 (string-count grid (lambda (x) (char=? #\0 x)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (row-col->cell row col)
    (+ (* row 9) col))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (cell->row-col cell)
     (cons (quotient cell 9)  (remainder cell 9)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-box-cell-list row col)
  (define (get-box-offset box)
    (cond
      ((between-inclusive box 0 2) 0)
      ((between-inclusive box 3 5) 18)
      ((between-inclusive box 6 8) 36)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (define (get-box-number row col)
      (+ (* (quotient row 3) 3) (quotient col 3)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (let ((box (get-box-number row col))(acc (list-accumulator)))
        (range-map (lambda(x)
            (range-map (lambda(y)
                (acc (+ x y  (* box 3) (get-box-offset box))))
            (numeric-range 0 3)))
        (numeric-range 0 26 9))
    (acc (eof-object))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-cell-list-content list grid)
  (map (lambda(x)(string-ref grid x))list))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-row-cell-list row )      
   (map (lambda (x) (+ (* row 9) x)) (range->list(numeric-range 0  9))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-col-cell-list col)
  (map (lambda (x) (+ x col)) '(0 9 18 27 36 45 54 63 72)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (check cell-content-list num grid) ;free to place number t/f  
  (let loop ((cell# 0))  
    (if (= (ascii-digit-value (list-ref cell-content-list cell#) 10) num)
      #f
      (if (= cell# 26) #t (loop (+ cell# 1))))))     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (define cells-affected-hash-table (make-hash-table #:test equal? #:size 9)) ; Create a hash table using equal? for key comparison
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (define all-possibles-for-cell-hash-table (make-hash-table #:test equal? #:size 81))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (define (fill-cells-affected-hash-table)
  ;;fills table with list of cells in each row col box thet affects each key cell cell
   (range-map (lambda (cell) 
     (let* ((row-col-pair (cell->row-col cell)) (row (car row-col-pair)) (col (cdr row-col-pair) ))
       (hash-table-set! cells-affected-hash-table cell (append (get-row-cell-list row) (get-col-cell-list col) (get-box-cell-list row col))))
   )(numeric-range 0 81)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (define (possible? row col num grid)   
          (check (get-cell-list-content  (hash-table-ref cells-affected-hash-table (row-col->cell row col)) grid) num grid))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; set table key to cell = 
;; #\0 if cell value is not zero
;; or affected cells content list
(define (fill-all-possibles-for-cell-hash-table grid)  
  (define (list-or-zero cell grid)
    (if (eq? #\0 (string-ref grid cell))
          (begin
            (range->list 
              (range-filter  (lambda (num);;;;;     
                (check (get-cell-list-content  (hash-table-ref cells-affected-hash-table cell) grid) num grid))
              (numeric-range 1 10))))
          (list 0)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (range-map (lambda (cell)
      (hash-table-set! all-possibles-for-cell-hash-table cell (list-or-zero cell grid)))
    (numeric-range 0 81)))

(define (print-all-possibles-for-cell-hash-table)
  (let ((mega-list (list-accumulator)))
     (range-map (lambda (cell)     
       (mega-list (hash-table-ref all-possibles-for-cell-hash-table cell))
     )(numeric-range 0 81))
     (mega-list (eof-object))
     ))



(define (makeJSON)  
    (map (lambda(x) (displayln x)) (print-all-possibles-for-cell-hash-table)) 
    )


; (define (print-all-possibles-for-cell-hash-table)
;   (let ((mega-list (list-accumulator)))
;      (range-map (lambda (cell)     
;        (mega-list (hash-table-ref all-possibles-for-cell-hash-table cell))
;      )(numeric-range 0 81))
;      (mega-list (eof-object))
;      ))




; (define (accumulate-strings strings-list)
;   (let loop ((remaining strings-list) (accumulator '()))
;     (if (null? remaining)
;         ; The accumulator list is in reverse order, so we concatenate in reverse.
;         (string-concatenate-reverse accumulator)
;         (loop (cdr remaining)
;               ; Prepend the current string to the accumulator list
;               (cons (car remaining) accumulator)))))



; { "possibles": [ { 0 }, { 0,1} ] }

 ;(json->string  (list->vector `(((,(string->symbol "type") . "grid")) ((,(string->symbol "num") . ,(identity grid))))))
;. (list->vector(99 104 105 99 107 101 110 33))
;'[{"type":"cells"},{"data":[[1,2],[2],[3]]}]'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;(define (possibles->string)     ; (array  . ,list->vector)
;;;;;;;;(json->string (list->vector `(((type . "poss")) ((num . #(#(1 2) #(2) #(3))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (print-all-possibles-for-cell-hash-table)
  (let ((mega-list (list-accumulator)))
     (range-map (lambda (cell)     
       (mega-list (list->vector(hash-table-ref all-possibles-for-cell-hash-table cell)))
     )(numeric-range 0 81))
     (list->vector(mega-list (eof-object)))
     ))





(define (a) ((4 6 7 9) (0) (0) (4 5 7 8) (0) (4 8 9) (5 6 7 8) (5 8 9) (5 6 7 9) (0) (4 5 7 9) (0) (4 5 7) (2 4 5 7 9) (2 4 9) (2 5 6 7) (2 5 9) (0) (7 9) (5 7 9) (5 7 9) (3 5 7 8) (2 3 5 7 8 9) (0) (0) (1 2 5 8 9) (1 2 5 7 9) (0) (4 7 8 9) (3 4 7 9) (3 4 6 7 8) (3 4 6 7 8 9) (0) (1 3 6) (1 4 9) (1 4 6 9) (3 4 9) (0) (3 4 5 9) (0) (3 4 9) (3 4 9) (2 3 5) (0) (0) (1 3 4 7 9) (4 5 7 8 9) (3 4 5 7 9) (0) (3 4 6 7 8 9) (3 4 8 9) (1 3 5 6) (1 4 5 9) (1 4 5 6 9) (0) (2 4) (3 4) (0) (2 3 4 8) (0) (1 2 8) (0) (1 2 4) (3 4 6 7 9) (0) (3 4 6 7 9) (3 4 5 6 8) (2 3 4 5 6 8) (2 3 4 8) (2 5 7 8) (2 4 5 8) (2 4 5 7) (4 6 7) (2 4 7) (0) (4 5 6) (2 4 5 6) (1 2 4) (0) (0) (1 2 4 5 7)))

;(define (possibles->string)     ; (array  . ,list->vector)
;  (json->string (list->vector `(((type . "poss")) ((num . ,(list->vector `(#(1 2) ,(a (list 1 2)) #(3)))))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (define (possibles->string)     ; (array  . ,list->vector)
;   (json->string (list->vector `(((type . "poss")) ((num .  ,(a '(#(4 6 7 9) #(0) #(0) #(4 5 7 8) #(0) #(4 8 9) #(5 6 7 8)))))))))



(define (possibles->string)     ; (array  . ,list->vector)
  (let ((var (print-all-possibles-for-cell-hash-table) ))
  (json->string (list->vector `(((type . "poss")) ((num . ,(identity var)))))))

)










;;((4 6 7 9) (0) (0) (4 5 7 8) (0) (4 8 9) (5 6 7 8) (5 8 9) (5 6 7 9) (0) (4 5 7 9) (0) (4 5 7) (2 4 5 7 9) (2 4 9) (2 5 6 7) (2 5 9) (0) (7 9) (5 7 9) (5 7 9) (3 5 7 8) (2 3 5 7 8 9) (0) (0) (1 2 5 8 9) (1 2 5 7 9) (0) (4 7 8 9) (3 4 7 9) (3 4 6 7 8) (3 4 6 7 8 9) (0) (1 3 6) (1 4 9) (1 4 6 9) (3 4 9) (0) (3 4 5 9) (0) (3 4 9) (3 4 9) (2 3 5) (0) (0) (1 3 4 7 9) (4 5 7 8 9) (3 4 5 7 9) (0) (3 4 6 7 8 9) (3 4 8 9) (1 3 5 6) (1 4 5 9) (1 4 5 6 9) (0) (2 4) (3 4) (0) (2 3 4 8) (0) (1 2 8) (0) (1 2 4) (3 4 6 7 9) (0) (3 4 6 7 9) (3 4 5 6 8) (2 3 4 5 6 8) (2 3 4 8) (2 5 7 8) (2 4 5 8) (2 4 5 7) (4 6 7) (2 4 7) (0) (4 5 6) (2 4 5 6) (1 2 4) (0) (0) (1 2 4 5 7))
;'((foo . null) (bar . #t)))

;'{"type":"cells","data":[[1,2],[2],[3]]}'

;'[{"type":"grid"},{"num":"6324195878417526937598364…9365194278194278356523947861916583724478621935"}]
;(json->string '((foo . #(#(1 2)#(2)#(3)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(json->string '((foo . #(1 2 3))))
;'#(1 2 #(3 4) 4 ())
  ;(json->string  (list->vector `(((,(string->symbol "possibles") . ,(string->symbol "cells") ))))))
  ; (define (get-box-offset box)
  ;   (cond
  ;     ((between-inclusive box 0 2) 0)
  ;     ((between-inclusive box 3 5) 18)
  ;     ((between-inclusive box 6 8) 36)))

  
;  (define (get-box-number row col)
;       (+ (* (quotient row 3) 3) (quotient col 3)))


   ;  (define (get-box-number row col) 
  ;   (cond 
  ;     ((between-inclusive row 0 2) 
  ;       (cond 
  ;         ((between-inclusive col 0 2) 0)
  ;         ((between-inclusive col 3 5) 1)
  ;         ((between-inclusive col 6 8) 2)))
  ;     ((between-inclusive row 3 5) 
  ;       (cond
  ;         ((between-inclusive col 0 2) 3)
  ;         ((between-inclusive col 3 5) 4)
  ;         ((between-inclusive col 6 8) 5)))
  ;     ((between-inclusive row 6 8)
  ;       (cond 
  ;         ((between-inclusive col 0 2) 6)
  ;         ((between-inclusive col 3 5) 7)
  ;         ((between-inclusive col 6 8) 8))))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (define (print-all-possibles-for-cell-hash-table)
;      (range-map (lambda (cell)     
;        (display (list cell (hash-table-ref all-possibles-for-cell-hash-table cell)))(newline)
;      )(numeric-range 0 81)))

; (define (get-box-number row col) 
;     (cond 
;       ((or (= row 0) (= row 1) (= row 2))
;         (cond 
;           ((or (= col 0) (= col 1) (= col 2)) 0)
;           ((or (= col 3) (= col 4) (= col 5)) 1)
;           ((or (= col 6) (= col 7) (= col 8)) 2)))
;       ((or(= row 3) (= row 4) (= row 5))
;         (cond
;           ((or (= col 0) (= col 1) (= col 2)) 3)
;           ((or (= col 3) (= col 4) (= col 5)) 4)
;           ((or (= col 6) (= col 7) (= col 8)) 5)))      
;       ((or (= row 6) (= row 7) (= row 8))
;         (cond 
;           ((or (= col 0) (= col 1) (= col 2)) 6)
;           ((or (= col 3) (= col 4) (= col 5)) 7)
;           ((or (= col 6) (= col 7) (= col 8)) 8)))))