(import 
    ;; Load Chez Scheme primitives:
    (chezscheme)
    ;; Load provided compiler framework:
    (Framework driver)
    (Framework wrappers)
    (Framework match)
    (Framework helpers)
    ;; Load your passes from the files you wrote them in:
    (Compiler remove-complex-opera*)
    (Compiler optimize-direct-call)
    (Compiler expose-allocation-pointer)
    (Compiler uncover-assigned)
    (Compiler convert-assignments)
    (Compiler specify-representation)
    (Compiler convert-complex-datum) 
    (Compiler optimize-known-call)
    (Compiler remove-anonymous-lambda)
    (Compiler purify-letrec)
    (Compiler sanitize-binding-forms)              
    (Compiler flatten-set!)
    (Compiler impose-calling-conventions)
    (Compiler expose-memory-operands)
    (Compiler verify-uil)
    (Compiler uncover-free)
    (Compiler convert-closures)
    (Compiler uncover-frame-conflict)
    (Compiler optimize-jumps)
    (Compiler select-instructions)
    (Compiler introduce-allocation-forms)
    (Compiler uncover-register-conflict)
    (Compiler specify-representation)
    (Compiler normalize-context)
    (Compiler verify-scheme)
    (Compiler uncover-locals)
    (Compiler introduce-procedure-primitives)
    (Compiler remove-let)
    (Compiler discard-call-live)
    (Compiler assign-registers)
    (Compiler finalize-locations)
    (Compiler expose-frame-var)
    (Compiler expose-basic-blocks)
    (Compiler flatten-program)
    (Compiler lift-letrec)
    (Compiler generate-x86-64))




#;(pretty-print
 (sanitize-binding-forms
 (remove-anonymous-lambda
  (optimize-direct-call
(verify-scheme t1)))))

(define t1 '(let ((f.2 (lambda() '(2 3))))
              (let ([f.1 (lambda () '(1 2))]
                    [x.4 '1])
                (begin                  
                  (eq? (eq? (f.1) (f.1)) '#(32 (33 33) 34))
                  (set! x.4 (+ x.4 x.4))))))

(define t2 '(letrec ((f.2 (lambda (x.5) (+ x.5 '1)))
                     (g.1 (lambda (y.3) (set! f.2 '22)))
                     (a.7 '23))
              (begin 
                ;(set! f.2 (lambda (x.4) (- x.4 '1)))
                (+ (f.2  '1) (g.1 '1)))))
(define t108 '((letrec ([length.391 (lambda (ptr.392)
                              (if (null? ptr.392)
                                  '0
                                  (+ '1 (length.391 (cdr ptr.392)))))])
                 length.391)
               '(5 10 11 5 15)))
(pretty-print
(convert-assignments
 (purify-letrec
 (uncover-assigned
 (convert-complex-datum
  (verify-scheme t108))))))








