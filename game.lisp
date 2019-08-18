;;2048

(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload :sdl2)
  (ql:quickload :sdl2-image))

(defparameter *output* nil)

(defclass square ()
  ((value :initform 1 :accessor value)))

(defun play2048 (output)
  (setf *output* output)
  (let ((board (make-array '(4 4) :initial-element nil)))
    (setf (aref board 1 1) (make-instance 'square))
    (setf (aref board 0 0) (make-instance 'square))
    (setf (aref board 2 1) (make-instance 'square))
    (setf (aref board 3 1) (make-instance 'square))
    (sdl2:with-init (:everything)
      (sdl2-image:init '(:png))
      (sdl2:with-window (window)
        (sdl2:with-renderer (renderer window :flags '(:accelerated :presentvsync))
          (let* ((surface (sdl2-image:load-image "C:/Users/Lily/portacle/2048/two.png"))
                 (texture (sdl2:create-texture-from-surface renderer surface))
                 (scale 3)
                 (rect (sdl2:make-rect 10 10 (/ (sdl2:texture-width texture) scale) (/ (sdl2:texture-height texture) scale))))
            (sdl2:with-event-loop (:method :poll)
              (:keydown (:keysym keysym)
                        (let ((scancode (sdl2:scancode-value keysym)))
                          (cond
                            ((sdl2:scancode= scancode :scancode-escape)
                             (sdl2:push-event :quit))
                            ((sdl2:scancode= scancode :scancode-up)
                             (dotimes (x 4)
                               (dotimes (y 4)
                                 (when (aref board y x)
                                   (let ((i
                                           (do ((i (1- y) (decf i)))
                                               ((minusp i) (1+ i))  ;;(minusp i) is the terminating condition (i < 0); (1+ i) is the place of the return value
                                             (when (aref board i x)
                                               (return (1+ i))))))
                                     (let ((square (aref board y x)))
                                       (setf (aref board y x) nil
                                             (aref board i x) square))))))))))
              (:idle ()
                     (sdl2:set-render-draw-color renderer 0 0 0 0)
                     (sdl2:render-clear renderer)
                     (dotimes (y 4)
                       (dotimes (x 4)
                         (when (aref board y x)
                           (sdl2:render-copy renderer texture :dest-rect (sdl2:make-rect (+ 10 (* x (+ 10 (/ (sdl2:texture-width texture) scale))))
                                                                                         (+ 10 (* y (+ 10 (/ (sdl2:texture-height texture) scale))))
                                                                                         (/ (sdl2:texture-width texture) scale)
                                                                                         (/ (sdl2:texture-height texture) scale))))))
                     (sdl2:render-present renderer))
              ;; open(name="bar", mode="foo")
              (:quit ()
                     t))))))))
