;;;************************************************************************
;;;*common.scm
;;;*
;;;*     This file contains generic alaqil GOOPS classes for generated
;;;*     GOOPS file support
;;;************************************************************************

(define-module (alaqil alaqilrun))

(define-module (alaqil common)
  #:use-module (oop goops)
  #:use-module (alaqil alaqilrun))

(define-class <alaqil-metaclass> (<class>)
  (new-function #:init-value #f))

(define-method (initialize (class <alaqil-metaclass>) initargs)
  (slot-set! class 'new-function (get-keyword #:new-function initargs #f))
  (next-method))

(define-class <alaqil> () 
  (alaqil-smob #:init-value #f)
  #:metaclass <alaqil-metaclass>
)

(define-method (initialize (obj <alaqil>) initargs)
  (next-method)
  (slot-set! obj 'alaqil-smob
    (let ((arg (get-keyword #:init-smob initargs #f)))
      (if arg
        arg
        (let ((ret (apply (slot-ref (class-of obj) 'new-function) (get-keyword #:args initargs '()))))
          ;; if the class is registered with runtime environment,
          ;; new-Function will return a <alaqil> goops class.  In that case, extract the smob
          ;; from that goops class and set it as the current smob.
          (if (slot-exists? ret 'alaqil-smob)
            (slot-ref ret 'alaqil-smob)
            ret))))))

(define (display-address o file)
  (display (number->string (object-address o) 16) file))

(define (display-pointer-address o file)
  ;; Don't fail if the function alaqil-PointerAddress is not present.
  (let ((address (false-if-exception (alaqil-PointerAddress o))))
    (if address
	(begin
	  (display " @ " file)
	  (display (number->string address 16) file)))))

(define-method (write (o <alaqil>) file)
  ;; We display _two_ addresses to show the object's identity:
  ;;  * first the address of the GOOPS proxy object,
  ;;  * second the pointer address.
  ;; The reason is that proxy objects are created and discarded on the
  ;; fly, so different proxy objects for the same C object will appear.
  (let ((class (class-of o)))
    (if (slot-bound? class 'name)
	(begin
	  (display "#<" file)
	  (display (class-name class) file)
	  (display #\space file)
	  (display-address o file)
	  (display-pointer-address o file)
	  (display ">" file))
	(next-method))))
                                              
(export <alaqil-metaclass> <alaqil>)

;;; common.scm ends here
