(require 'lsp-mode)
(add-hook 'go-mode-hook
          (lambda ()
            (setq tab-width 2)
            (lsp)
            (add-hook 'before-save-hook 'gofmt-before-save)
            (set (make-local-variable 'whitespace-style) '(face trailing lines-tail empty space))
            (local-set-key (kbd "C-c C-f") 'gofmt)
            (local-set-key (kbd "C-c C-t") 'xref-find-type-definitions-other-window)
            (local-set-key (kbd "C-c C-o") 'xref-find-definitions-other-window)
            (local-set-key (kbd "C-c C-j") 'xref-find-definitions)
            (local-set-key (kbd "C-c C-i") 'lsp-ui-peek-find-implementation)
            (local-set-key (kbd "C-c C-n") 'lsp-rename)
            (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)
            (local-set-key (kbd "C-c e") 'flycheck-previous-error)
            (local-set-key (kbd "C-c C-e") 'flycheck-next-error)
            (local-set-key (kbd "C-c C-d") 'lsp-describe-thing-at-point-minibuffer)
))
