(use-package neotree
  :custom
  (neo-keymap-style 'concise)
  (neo-banner-message nil)
  (neo-show-hidden-files t)
  (neo-create-file-auto-open t)
  (neo-persist-show nil)
  (neo-smart-open t)
  (neo-vc-integration '(face char))
  :bind
  ("C-x \"" . neotree-toggle)
  :hook
  (neotree-mode . (lambda ()
                    (define-key neotree-mode-map (kbd "C-g") 'neotree-hide)))
  :config
  ;; Disable helm for neotree functions
  (add-to-list 'helm-completing-read-handlers-alist '(neo-buffer--rename-node . nil))
  (add-to-list 'helm-completing-read-handlers-alist '(neotree-create-node . nil)))
