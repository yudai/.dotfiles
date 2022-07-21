;; Go mode configuration
(defun my-go-mode-setup ()
  "Setup Go mode with or without LSP"
  (message "Setting up Go mode...")
  (setq tab-width 2)
  (when (derived-mode-p 'go-ts-mode)
    (setq go-ts-mode-indent-offset 2))
  
  ;; Basic settings that work without LSP
  (set (make-local-variable 'whitespace-style) '(face trailing lines-tail empty space))
  (local-set-key (kbd "C-c C-f") 'gofmt)
  
  ;; Try to enable LSP if available
  (when (require 'lsp-mode nil t)
    (message "LSP-mode found, enabling...")
    (condition-case err
        (progn
          (lsp-deferred)
          (message "LSP activated for Go mode")
          ;; LSP-dependent hooks and keybindings
          (add-hook 'before-save-hook #'lsp-format-buffer nil 'local)
          (add-hook 'before-save-hook #'lsp-organize-imports nil 'local)
          (local-set-key (kbd "C-c C-t") 'xref-find-type-definitions-other-window)
          (local-set-key (kbd "C-c C-o") 'xref-find-definitions-other-window)
          (local-set-key (kbd "C-c C-j") 'xref-find-definitions)
          (when (require 'lsp-ui nil t)
            (local-set-key (kbd "C-c C-i") 'lsp-ui-peek-find-implementation))
          (local-set-key (kbd "C-c C-n") 'lsp-rename)
          (local-set-key (kbd "C-c C-d") 'lsp-describe-thing-at-point-minibuffer))
      (error 
       (message "Failed to activate LSP for Go: %s. Install missing packages with M-x package-install-selected-packages" err)
       (message "LSP packages needed: spinner, dash, f, s, ht")))))

(use-package go-mode
  :hook (go-mode . my-go-mode-setup))

(use-package go-ts-mode
  :hook (go-ts-mode . my-go-mode-setup))

;; Configure LSP for Go when available
(with-eval-after-load 'lsp-mode
  ;; Configure Go-specific LSP settings
  (when (require 'lsp-go nil t)
    (setq lsp-go-use-gofumpt t)
    (setq lsp-go-goimports-local ""))
  
  ;; Ensure gopls is registered for go-mode and go-ts-mode
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "gopls")
                    :major-modes '(go-mode go-ts-mode)
                    :priority 0
                    :initialization-options (lambda ()
                                              (list :usePlaceholders t
                                                    :completeUnimported t))
                    :server-id 'gopls)))
