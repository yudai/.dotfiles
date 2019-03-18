(require 'lsp-ui)
(add-hook 'lsp-mode-hook 'lsp-ui-mode)

(define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
(define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)

(define-key global-map (kbd "C-c C-g") 'helm-imenu)
(define-key global-map (kbd "C-c g") 'helm-lsp-workspace-symbol)
