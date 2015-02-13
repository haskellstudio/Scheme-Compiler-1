(library (Compiler uncover-frame-conflict)
  (export
   uncover-frame-conflict
  )
  (import
    ;; Load Chez Scheme primitives:
    (chezscheme)
    ;; Load compiler framework:
    (Framework match)
    (Framework helpers)
    (Compiler common))
    
  (define-who (uncover-frame-conflict program)
    (define (frame-var-or-uvar? x)
      (or (frame-var? x) (uvar? x)))
    ;; Validate Body
    (define (Body exp)
      (match exp
        ((locals (,x ...) ,y)  `(locals (,x ...)                   
                                        (frame-conflict ,(get-conflict y x frame-var-or-uvar?) ,y)))))

    ;; Validate letrec label exp :   [label (lambda() Tail)]
    (define (Exp exp)                   ;get-trace-define
      (match exp
        ((,x (lambda () ,tail)) `(,x (lambda () ,(Body tail))))))

    ;; Validate Program
    (define (Program exp)                   ;get-trace-define
      (match exp
        ((letrec (,[Exp -> x] ...) ,y) `(letrec (,x ...) ,(Body y)))))

    (define (uncover-frame-conflict exp)                   ;get-trace-define
      (Program exp))
    
    (uncover-frame-conflict program)))
