(use-package flycheck
  :hook (after-init . global-flycheck-mode)
  :custom
  (flycheck-rubocop-lint-only t)
  (flycheck-display-errors-function #'my-flycheck-display-error-messages)
  :config
  (when (file-exists-p "~/.emacs.d/lisp/default-to-cycling-flycheck.el")
    (load "default-to-cycling-flycheck.el"))
  
  (require 'eldoc)
  (defun my-flycheck-display-error-messages (errors)
    (when (and
           errors
           (flycheck-may-use-echo-area-p)
           (not this-command)
           (eldoc--message-command-p last-command))
      (let ((messages (mapcar #'flycheck-error-format-message-and-id errors)))
        (display-message-or-buffer (string-join messages "\n\n")
                                   flycheck-error-message-buffer)))))

(custom-set-faces
 '(flycheck-error ((t (:underline t :foreground "orange"))))
 '(flycheck-warning ((t (:inherit nil)))))
