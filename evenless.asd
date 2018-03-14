;;;; evenless.asd

(asdf:defsystem #:evenless
  :description "Evenless is frontend to the notmuch MUA."
  :author "Moritz Schönherr <moritz.schoenherr@posteo.net>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "evenless"))
  :depends-on ("mcclim" "clim-listener"))
