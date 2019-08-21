(declare (hide alaqil-initialize))

(define (alaqil-initialize obj initargs create)
     (slot-set! obj 'alaqil-this
        (if (memq 'alaqil-this initargs)
            (cadr initargs)
            (let ((ret (apply create initargs)))
              (if (instance? ret)
                (slot-ref ret 'alaqil-this)
                ret)))))

(define-class <alaqil-metaclass-$module> (<class>) (void))

(define-method (compute-getter-and-setter (class <alaqil-metaclass-$module>) slot allocator)
  (if (not (memq ':alaqil-virtual slot))
    (call-next-method)
    (let ((getter (let search-get ((lst slot))
                    (if (null? lst)
                      #f
                      (if (eq? (car lst) ':alaqil-get)
                        (cadr lst)
                        (search-get (cdr lst))))))
          (setter (let search-set ((lst slot))
                    (if (null? lst)
                      #f
                      (if (eq? (car lst) ':alaqil-set)
                        (cadr lst)
                        (search-set (cdr lst)))))))
      (values
        (lambda (o) (getter (slot-ref o 'alaqil-this)))
	(lambda (o new) (setter (slot-ref o 'alaqil-this) new) new)))))
