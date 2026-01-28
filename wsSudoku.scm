(import
  (chicken foreign)    
  (chicken base)
  (chicken platform)
  (scheme)
  (srfi 196)
  (srfi 130)
  (srfi 196)
  (srfi 158)  
  (srfi 69)
  (srfi 13)
  ;(schemepunk json)
  (chicken process-context) srfi-18)

(load "lib/cells.scm")
(load "lib/175.scm")

(define range08 (numeric-range 0  8))
(define grid1 "530070000600195000098000060800060003400803001700020006060000280000419005000080079")
(define grid2 "032010000801000003000006400200005000060100078000200000500907060010000000008000930")
(define grid3 "103070002000000040090005001020100503007000200405002060200800030050000000800020709")



;(define (identity x) x)

; (define (grid-string grid)    
;   (json->string  (list->vector `((("type" . "grid")) (("num" . ,(identity grid)))))))
(define grid-string     
  "{{\"type\":\"grid\"}{\"num\":\"103070002000000040090005001020100503007000200405002060200800030050000000800020709\"}}")
  
 ; {{"type" : "grid"}{"num" : "103070002000000040090005001020100503007000200405002060200800030050000000800020709"}}

(define-syntax let/ec 
  (syntax-rules ()
    ((_ return body ...)
     (call-with-current-continuation
      (lambda (return)
        body ...)))))

(define for (lambda (row end func)
      (let loop ((index row))
        (if (> index end) #t
          (begin
            (func index)
            (loop (+ index 1)))))))


(define (solve grid)
  (let/ec return    
    (range-map (lambda (row) (range-map (lambda(col)  
        (if (=(ascii-digit-value (string-ref grid (row-col->cell row col)) 10)  0)        
           (let num-loop ((num 1))             
             (if (not (= 10 num))
               (begin            
                 (if (possible? row col num grid)
                   (begin
                     (string-set! grid  (row-col->cell row col) (ascii-nth-digit num))
                     (solve grid)                    
                     (when (no-zeros-left? grid)(return 0))                     
                     (string-set! grid  (row-col->cell row col) (ascii-nth-digit 0))))
                 (num-loop (+ 1 num)))                                              
                 (return 0)))))
    (numeric-range 0  9)))(numeric-range 0  9))
  (print-grid grid)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#>
 extern char* wsResponse; 
 extern void clearResponse(void);
<#

;(define-foreign-variable wsResponse  (c-pointer char) "wsResponse")
(define-foreign-variable wsResponse  c-string "wsResponse")

(define clearResponse
(foreign-lambda void "clearResponse")
)

; (define (runthis grid)
;   (print "2\n")
;   (init-cells-affected-hash-table)
;    (print "3\n")
;   ;(init-find-all-possibles-table grid)
;    (print "4\n")
;   (solve (string-copy grid))
;    (print "5\n")
;   ;(range->list (split grid))
;   (print-grid grid)
;   ;(print-find-all-possibles-table)
; )

(define null-string-val #f)

(define (start)

(let loop ()
  (if (not (equal? wsResponse #f))
    (begin 
      ;(runthis grid2)
      ;(getbuttons wsResponse)
      ;(processString wsResponse)
      ;(print wsResponse)
      (ws_send_txt "{{\"type\":\"grid\"}{\"num\":\"103070002000000040090005001020100503007000200405002060200800030050000000800020709\"}}" 4)
      (clearResponse)
    )
  )
  (thread-sleep! .01)
(loop)))


; (define (start)
; (runthis grid2)

; )


;(solve (string-copy grid2))

 (define (processString msg)
         (cond 
             ((string=? msg "button1")(solve (string-copy grid1)))
             ((string=? msg "button2")(solve (string-copy grid2)))
             ((string=? msg "button3")(solve (string-copy grid3)))
             ((string=? msg "button4")(ws_send_txt "{{\"type\":\"grid\"}{\"num\":\"103070002000000040090005001020100503007000200405002060200800030050000000800020709\"}}" gblFd))
            ; ((string=? msg "button5")(ws_send_txt (grid-string grid2) gblFd))
            ; ((string=? msg "button6")(ws_send_txt (grid-string grid3) gblFd))
            ))
; ;;;;;;



; (define  (processString msg)
;         (cond 
;             ((string=? msg "button1")(print "1"))
;             ((string=? msg "button2")(print "1"))
;             ((string=? msg "button3")(print "1"))
;             ((string=? msg "button4")(print "1"))
;             ((string=? msg "button5")(print "1"))
;             ((string=? msg "button5")(print "1"))))

(return-to-host)


