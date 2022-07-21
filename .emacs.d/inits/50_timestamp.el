;; Timestamp insertion utility
(use-package emacs
  :bind
  ("C-c C-t" . insert-current-time)
  :config
  (defun insert-current-time()
    "Insert current timestamp in ISO format"
    (interactive)
    (insert
     (concat
      (format-time-string "%Y-%m-%dT%T")
      ((lambda (x) (concat (substring x 0 3) ":" (substring x 3 5)))
       (format-time-string "%z"))))))
