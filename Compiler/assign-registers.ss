(library (Compiler assign-registers)
  (export
   assign-registers
  )
  (import
    ;; Load Chez Scheme primitives:
    (chezscheme)
    ;; Load compiler framework:
    (Framework match)
    (Framework helpers))
  ;;;; TODO Need to add machine constraints error 
  ;; If it is a binary operator or not
  (define (binop? exp)                   ;get-trace-define
    (define binops '(+ - * logand logor sra))
    (and (memq exp binops) #t))
  
  ;; If it is a relational operator or not
  (define (relop? exp)                   ;get-trace-define
    (define relops '(< > = <= >=))
    (and (memq exp relops) #t))
  
  ;; A variable is a either a register or a frame variable 
  (define (var? exp)                   ;get-trace-define
                (or (register? exp) (frame-var? exp) (uvar? exp)))  
  ;; extract-suffix name -> use this to enforce unique name
  ;; Using define-who macro 
  (define-who (assign-registers program)

    (define (map-to-reg ls s)
      (cond
       ((null? s) '())
       ((memq (caar s) ls) (cons (cadar s) (map-to-reg ls (cdr s))))
       (else (map-to-reg ls (cdr s)))))
    
    ;; Gets a sorted list by degree
    (define (assign cg regls s)
      (cond
       ((null? cg) (reverse s))
       ((null? regls) (errorf who "No registers left, Have to spill !!! ~s" cg))
       (else (let* ((k (cdar cg))
                    (aregls (difference regls (union k (map-to-reg k s)))))
               (if (null? regls)
                   (errorf who "Cannot allocate register for ~s" (car k))
                   (assign (cdr cg) regls
                           (cons `(,(caar cg) ,(car aregls)) s)))))))

    (define (Body exp)
      (match exp
        ((locals (,x ...) (register-conflict ,cg ,y))
         (let ((ar (assign (sort (lambda(x y) (< (length x) (length y))) cg) registers '())))
           `(locate ,ar ,y)))))


    ;; Validate letrec label exp :   [label (lambda() Tail)]
    (define (Exp exp)                   ;get-trace-define
      (match exp
        ((,x (lambda () ,tail)) `(,x (lambda () ,(Body tail))))))

    ;; Validate Program
    (define (Program exp)                   ;get-trace-define
      (match exp
        ((letrec (,[Exp -> x] ...) ,y) `(letrec (,x ...) ,(Body y)))))
    (Program program)))
