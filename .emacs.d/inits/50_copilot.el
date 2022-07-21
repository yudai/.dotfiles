;; GitHub Copilot configuration
(use-package copilot
  :ensure nil  ; This is typically installed manually or via a specific package manager
  :bind (:map copilot-completion-map
              ("C-x C-x" . copilot-accept-completion-by-line)
              ("TAB" . copilot-accept-completion)
              ("C-g" . copilot-clear-overlay))
  :hook (prog-mode . copilot-check-and-enable)
  :config
  (defun copilot-check-and-enable ()
    "Enable copilot mode only if the language server is available"
    (when (executable-find "node")
      (condition-case err
          (progn
            (copilot-mode 1)
            (message "Copilot activated"))
        (error 
         (message "Copilot language server not found. Install with: npm install -g @github/copilot-language-server")
         nil)))))
