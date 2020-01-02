(defun xref-find-type-definitions-other-window () "find type definitions in other window" (interactive) (lsp-find-type-definition :display-action 'window) )

(define-key global-map (kbd "C-c C-g") 'helm-lsp-workspace-symbol)

(defun lsp-describe-thing-at-point-minibuffer ()
  "Display the full documentation of the thing at point."
  (interactive)
  (let ((contents (-some->> (lsp--text-document-position-params)
                            (lsp--make-request "textDocument/hover")
                            (lsp--send-request)
                            (gethash "contents"))))
    (if (and contents (not (equal contents "")) )
        (progn
            (message (lsp--render-on-hover-content contents t))))))

(setq lsp-eldoc-enable-signature-help t)
(setq lsp-eldoc-prefer-signature-help t)
(setq lsp-eldoc-render-all t)
(setq lsp-enable-snippet nil)
(setq lsp-ui-doc-enable nil)
(setq lsp-ui-sideline-enable nil)
(setq lsp-prefer-flymake nil)
