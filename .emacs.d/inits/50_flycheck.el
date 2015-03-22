(require 'flycheck)

(add-hook 'after-init-hook #'global-flycheck-mode)

(defun my-flycheck-display-error-messages (errors)
  (when (and
         errors
         (flycheck-may-use-echo-area-p)
         (not this-command)
         (eldoc--message-command-p last-command))
    (let ((messages (mapcar #'flycheck-error-format-message-and-id errors)))
      (display-message-or-buffer (string-join messages "\n\n")
                                 flycheck-error-message-buffer))))

(eval-after-load 'flycheck
  '(custom-set-variables
    '(flycheck-display-errors-function
      #'my-flycheck-display-error-messages)))

(set-face-attribute 'flycheck-error nil :underline t)
