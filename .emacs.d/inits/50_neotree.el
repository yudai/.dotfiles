(setq neo-keymap-style 'concise)
(setq neo-banner-message nil)
(setq neo-show-hidden-files t)
(setq neo-create-file-auto-open t)
(setq neo-persist-show t)
(setq neo-smart-open t)
(setq neo-vc-integration '(face char))

(when neo-persist-show
  (add-hook 'popwin:before-popup-hook
            (lambda () (setq neo-persist-show nil)))
  (add-hook 'popwin:after-popup-hook
                        (lambda () (setq neo-persist-show t))))

(define-key global-map (kbd "C-x \"") 'neotree-toggle)

(add-hook 'neotree-mode-hook
          (lambda ()
            (define-key neotree-mode-map (kbd "C-g") 'neotree-hide)))

; Disable helm
(add-to-list 'helm-completing-read-handlers-alist '(neo-buffer--rename-node . nil))
(add-to-list 'helm-completing-read-handlers-alist '(neotree-create-node . nil))
