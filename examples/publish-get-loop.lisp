;;; -*- Package: de.setf.amqp.user; -*-

(in-package :de.setf.amqp.user)

;;;  This file demonstrates examples of use of the 'de.setf.amqp' library.
;;;
;;;  Copyright 2010 [james anderson](mailto:james.anderson@setf.de
;;;  'de.setf.amqp' is free software: you can redistribute it and/or modify it under the terms of version 3
;;;  of the GNU Affero General Public License as published by the Free Software Foundation.
;;;
;;;  'setf.amqp' is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
;;;  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;;;  See the Affero General Public License for more details.
;;;
;;;  You should have received a copy of the GNU Affero General Public License along with 'de.setf.amqp'.
;;;  If not, see the GNU [site](http://www.gnu.org/licenses/).


;;; to observe the protocol exchange
;;; (setf *log-level* :debug)

(defun publish-get-loop (publish-channel get-channel data count
                                         &key (queue "q1") (exchange "ex")
                                         (routing-key "/")
                                         ((:log-level *log-level*) *log-level*))
  (let* ((publish-basic (amqp:basic publish-channel))
         (get-basic (amqp:basic get-channel))
         (exchange (amqp:exchange publish-channel :exchange exchange :type "direct"))
         (publish-queue (amqp:queue publish-channel :queue queue))
         (get-queue (amqp:queue get-channel :queue queue)))
    
    (amqp:request-declare publish-queue)
    (amqp:request-declare get-queue)
    (amqp:request-bind publish-queue :exchange exchange :queue publish-queue :routing-key routing-key)
    
    (dotimes (i count)
      (dolist (datum data)
        (amqp:request-publish publish-basic :exchange exchange :body datum :routing-key routing-key)
        (amqp:request-get get-basic :queue get-queue)))))
      

(defparameter *c* (make-instance 'amqp:connection :uri "amqp://guest:guest@localhost/"))
(defparameter *ch1* (amqp:channel *c* :uri (uri "amqp:/")))
(defparameter *ch2* (amqp:channel *c* :uri (uri "amqp:/")))

(publish-get-loop *ch1* *ch2* '("this is a test") 1)

;;; (time (publish-get-loop *ch1* *ch2* '("a") 10000))

;;; os x, g5-2.5g, qpid-0.5
;;; sbcl : 52 seconds,  154 MB
;;; mcl  : 120 seconds, 11 MB
;;; ccl  : 52 seconds,  17.8 MB