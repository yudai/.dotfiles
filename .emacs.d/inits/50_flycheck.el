(require 'flycheck)

(add-hook 'after-init-hook #'global-flycheck-mode)

(require 'eldoc)
(defun my-flycheck-display-error-messages (errors)
  (when (and
         errors
         (flycheck-may-use-echo-area-p)
         (not this-command)
         (eldoc--message-command-p last-command))
    (let ((messages (mapcar #'flycheck-error-format-message-and-id errors)))
      (display-message-or-buffer (string-join messages "\n\n")
                                 flycheck-error-message-buffer))))

(setq flycheck-display-errors-function #'my-flycheck-display-error-messages)
(setq flycheck-rubocop-lint-only t)
