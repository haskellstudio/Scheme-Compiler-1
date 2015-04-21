(library (Compiler uncover-assigned)
  (export
   uncover-assigned
  )
  (import
    ;; Load Chez Scheme primitives:
    (chezscheme)
    ;; Load compiler framework:
    (Framework match)
    (Framework helpers)
    (Compiler common))
  
  (define-who (uncover-assigned program)        
    (define (Exp* expls)
      (cond
       ((null? expls) (values expls '()))
       (else (let*-values (((x l1) (Exp (car expls)))
                           ((y l2) (Exp* (cdr expls))))
               (values (cons x y) (union l1 l2))))))

    (define (Exp exp)                   ;get-trace-define
      (match exp
        ((,x (lambda (,y ...) ,z)) (let-values (((z ls) (Expr z)))
                                     (values `(,x (lambda (,y ...) ,z)) ls)))))


    
    (define (Expr* expls)
      (cond
       ((null? expls) (values expls '()))
       (else (let*-values (((x l1) (Expr (car expls)))
                           ((y l2) (Expr* (cdr expls))))
               (values (cons x y) (union l1 l2))))))
    
    (define (Expr exp)
      (match exp
        ((if ,x ,y ,z) (let*-values (((x l1) (Expr x))
                                     ((y l2) (Expr y))
                                     ((z l3) (Expr z)))                                                       
                         (values `(if ,x ,y ,z) (append l1 (append l2 l3)))))
        ((begin ,x ...) (let-values (((x ls) (Expr* x)))
                          (values `(begin ,x ...) ls)))
        ((let ((,x ,y) ...) ,z) (let*-values (((y l1) (Expr* y))
                                              ((z l2) (Expr z)))
                                  (let* ((un-ls (union l1 l2))
                                         (as-ls (intersection x (union l1 l2)))
                                         (rem-ls (difference un-ls as-ls)))
                                    (values `(let ,(map (lambda(x y) `(,x ,y)) x y) (assigned ,as-ls ,z)) rem-ls))))
        ((letrec (,x ...) ,y) (let*-values (((x l1) (Exp* x))
                                            ((y l2) (Expr y)))
                                (values `(letrec (,x ...) ,y) (append l1 l2))))
        ((lambda (,x ...) ,z) (let-values (((z ls) (Expr z)))
                                (values `(lambda (,x ...) ,z) ls)))        
        ((quote ,x) (values exp '()))
        ((set! ,x ,y) (let-values (((y ls) (Expr y)))
                        (values `(set! ,x ,y) (union `(,x) ls))))
        ((,x ,y ...) (guard (prim? x)) (let-values (((y ls) (Expr* y)))
                                         (values `(,x ,y ...) ls)))
        ((,x ...) (let-values (((x ls) (Expr* x)))
                    (values `(,x ...) ls)))
        (,x (guard (uvar? x)) (values exp '()))
        (,else (values exp '()))))
    
    (define (Program exp)                   ;get-trace-define
      ;; (unique-name-count 800)      
      (let-values (((exp ls) (Expr exp)))
        (if (null? ls)
            exp
            `(let ,ls ,exp))))

    (define (uncover-assigned exp)                   ;get-trace-define      
      (Program exp))
    
    (uncover-assigned program)))
