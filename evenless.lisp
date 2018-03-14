;;;; evenless.lisp

(in-package #:evenless)

(defmacro define-nm-command (command (result-var) &body body)
  "Given a symbol command that corresponds to a notmuch command,
define a function that binds the output of
notmuch command --format=sexp (search-string) to result-var and
executes the body." ; possibly allow definition of functions of arity 0
  (let ((command-name (string-downcase (symbol-name command)))
	(full-name (intern (with-output-to-string (s)
			     (princ 'nm- s)
			     (princ command s)))))
    `(defun ,full-name (search-string)
       (let ((,result-var (read-from-string
			  (with-output-to-string (out-s)
			    (uiop:run-program
			     (concatenate 'string "notmuch " ,command-name " --format=sexp " search-string)
			     :output out-s)))))
	 ,@body))))

(defun pluck-a-pair (some-list)
  "Plucks car and cadr of some-list and returns a (car .cadr)."
  (cons (car some-list) (cadr some-list)))

(defun list-to-alist (even-list)
  "Takes a list with an even number of args and returns an alist."
  (labels ((pluck-pairs (acc some-list)
	     (if (<= (length some-list) 1)
		 acc
		 (pluck-pairs (cons (pluck-a-pair some-list) acc) (cddr some-list)))))
    (reverse (pluck-pairs () even-list))))

(define-nm-command search (result) ; to be written
  (mapcar #'list-to-alist result))

(define-nm-command show (result) ; to be written
  (princ result))

(define-application-frame evenless ()
  ((search-results :initform nil :accessor search-results))
  (:panes
   (search-results :application
		   :display-function 'display-search-results
		   :height 400
		   :width 600)
   (prompt :interactor
	   :height 100
	   :width 600))
  (:layouts
   (default-layout (vertically ()
		     search-results
		     prompt))))

(defun display-search-results (frame pane)
  "Renders the search results on the pane."
  (let ((search-results (search-results frame)))
    (format pane "~{~a~%~}" search-results)))

(define-evenless-command (search-mail :name t) ((search-string 'string))
  (setf (search-results *application-frame*) (nm-search search-string)))
