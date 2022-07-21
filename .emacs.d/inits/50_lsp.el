(use-package lsp-mode
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-eldoc-enable-signature-help t)
  (lsp-eldoc-prefer-signature-help t)
  (lsp-eldoc-render-all t)
  (lsp-enable-snippet nil)
  (lsp-completion-enable t)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-modeline-code-actions-enable nil)
  (lsp-modeline-diagnostics-enable nil)
  (lsp-file-watch-threshold 20000)
  (lsp-log-io nil)
  (lsp-prefer-flymake nil)
  (lsp-response-timeout 300)
  (lsp-signature-auto-activate nil)
  (lsp-clients-go-server-args nil)
  :config
  
  (defun xref-find-type-definitions-other-window () 
    "find type definitions in other window" 
    (interactive) 
    (lsp-find-type-definition :display-action 'window))
  
  (when (fboundp 'helm-lsp-workspace-symbol)
    (define-key global-map (kbd "C-c C-g") 'helm-lsp-workspace-symbol))
  
  (defun lsp-describe-thing-at-point-minibuffer ()
    "Display the full documentation of the thing at point."
    (interactive)
    (let ((contents (-some->> (lsp--text-document-position-params)
                              (lsp--make-request "textDocument/hover")
                              (lsp--send-request)
                              (gethash "contents"))))
      (if (and contents (not (equal contents "")) )
          (progn
              (message (lsp--render-on-hover-content contents t)))))))

(use-package lsp-ui
  :after lsp-mode
  :custom
  (lsp-ui-doc-enable nil)
  (lsp-ui-sideline-enable nil))

(custom-set-faces
 '(lsp-ui-sideline-global ((t (:background "#6c6c6c"))))
 '(lsp-ui-sideline-symbol ((t (:foreground "brightblack" :box (:line-width -1 :color "grey") :height 0.99))))
 '(lsp-ui-sideline-symbol-info ((t (:slant italic :height 0.99)))))
