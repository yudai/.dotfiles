;; https://gist.github.com/Blaisorblade/c7349438b06e7b1e034db775408ac4cb

;; Caveat: I'm an Elisp noob. I expect this will break if invoked before flycheck mode is possible, and am not sure that's possible.

;; Invoke flycheck preferentially when flycheck-mode is enabled.
;; My own workaround for https://github.com/commercialhaskell/intero/issues/268.

(defun flycheck-or-norm-next-error (&optional n reset)
  (interactive "P")
  (if flycheck-mode
      (flycheck-next-error n reset)
    (next-error n reset)))
(defun flycheck-or-norm-previous-error (&optional n)
  (interactive "P")
  (if flycheck-mode
      (flycheck-previous-error n)
    (previous-error n)))

(global-set-key (kbd "M-g n") 'flycheck-or-norm-next-error)
(global-set-key (kbd "M-g p") 'flycheck-or-norm-previous-error)

;; Optional: ensure flycheck cycles, both when going backward and forward.
;; Tries to handle arguments correctly.
;; Since flycheck-previous-error is written in terms of flycheck-next-error,
;; advising the latter is enough.
(defun flycheck-next-error-loop-advice (orig-fun &optional n reset)
  ; (message "flycheck-next-error called with args %S %S" n reset)
  (condition-case err
      (apply orig-fun (list n reset))
    ((user-error)
     (let ((error-count (length flycheck-current-errors)))
       (if (and
            (> error-count 0)                   ; There are errors so we can cycle.
            (equal (error-message-string err) "No more Flycheck errors"))
           ;; We need to cycle.
           (let* ((req-n (if (numberp n) n 1)) ; Requested displacement.
                  ; An universal argument is taken as reset, so shouldn't fail.
                  (curr-pos (if (> req-n 0) (- error-count 1) 0)) ; 0-indexed.
                  (next-pos (mod (+ curr-pos req-n) error-count))) ; next-pos must be 1-indexed
             ; (message "error-count %S; req-n %S; curr-pos %S; next-pos %S" error-count req-n curr-pos next-pos)
             ; orig-fun is flycheck-next-error (but without advise)
             ; Argument to flycheck-next-error must be 1-based.
             (apply orig-fun (list (+ 1 next-pos) 'reset)))
         (signal (car err) (cdr err)))))))

(advice-add 'flycheck-next-error :around #'flycheck-next-error-loop-advice)


;; The following might be needed to ensure flycheck is loaded.
;; Hooking is required if flycheck is installed as an ELPA package (from any repo).
;; If you use ELPA, you might want to merge this with any existing hook you might have.
(add-hook 'after-init-hook
          #'(lambda ()
              (after-packages-loaded-hook)))

(defun after-packages-loaded-hook ()
  (require 'flycheck))
