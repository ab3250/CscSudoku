#>
 extern char* wsResponse; 
 extern void clearResponse(void);
 extern  int ws_sendframe_txt(int fd, const char *msg, bool broadcast);
 extern int globalfd;
<#


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
  (medea)
  ;(json)
  ;(abnf)
  (chicken process-context) srfi-18)

(load "lib/cells.scm")
(load "lib/175.scm")



(define clearResponse
(foreign-lambda void "clearResponse"))

(define ws_send_txt (foreign-lambda* 
    int ((int fd) (c-string msg) (bool broadcast))
     "ws_sendframe_txt(fd, msg, broadcast);"))

(define-foreign-variable wsResponse  c-string "wsResponse")
(define-foreign-variable globalfd  int "globalfd")
(define type (string->symbol "type"))
(define num (string->symbol "num"))
(define range08 (numeric-range 0  8))
(define null-string-val #f)

(define (grid->string grid)    
  (json->string  (list->vector `(((type . "grid")) ((num . ,(identity grid)))))))


(define grid1 "530070000600195000098000060800060003400803001700020006060000280000419005000080079")
(define grid2 "032010000801000003000006400200005000060100078000200000500907060010000000008000930")
(define grid3 "103070002000000040090005001020100503007000200405002060200800030050000000800020709")

(define-syntax let/ec 
  (syntax-rules ()
    ((_ return body ...)
     (call-with-current-continuation
      (lambda (return)
        body ...)))))

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
  (ws_send_txt globalfd (grid->string grid) #f)
  (print-grid grid)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 (define (runthis grid)
   (print "2\n")
   (init-cells-affected-hash-table)  
   (init-find-all-possibles-hash-table grid)
   (solve (string-copy grid))   
   ;(range->list (split grid))
   (print-grid grid)
   (print-find-all-possibles-hash-table)
   )

(define (start)

(let loop ()
  (if (not (equal? wsResponse #f))
    (begin 
      ;(runthis grid2)
      ;(getbuttons wsResponse)
      (processString wsResponse)
      ;(print wsResponse)
      
      ;
      (clearResponse)
    )
  )
  (thread-sleep! .01)
(loop)))

(define (processString msg)
  (cond 
    ((string=? msg "button1")(runthis grid1))
    ((string=? msg "button2")(runthis grid2))
    ((string=? msg "button3")(runthis grid3))
    ((string=? msg "button4")(ws_send_txt globalfd (grid->string grid1) #f))
    ((string=? msg "button5")(ws_send_txt globalfd (grid->string grid2) #f))
    ((string=? msg "button6")(ws_send_txt globalfd (grid->string grid3) #f))))
;;;;;;;



; (define  (processString msg)
;         (cond 
;             ((string=? msg "button1")(print "1"))
;             ((string=? msg "button2")(print "1"))
;             ((string=? msg "button3")(print "1"))
;             ((string=? msg "button4")(print "1"))
;             ((string=? msg "button5")(print "1"))
;             ((string=? msg "button5")(print "1"))))

(return-to-host)


