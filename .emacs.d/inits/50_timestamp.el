(defun insert-current-time()
  (interactive)
  (insert
   (concat
    (format-time-string "%Y-%m-%dT%T")
    ((lambda (x) (concat (substring x 0 3) ":" (substring x 3 5)))
     (format-time-string "%z")))))


(define-key global-map (kbd "C-c C-t") `insert-current-time)
