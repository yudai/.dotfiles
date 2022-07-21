(use-package helm
  :init
  (helm-mode 1)
  :custom
  (helm-truncate-lines t)
  (helm-candidate-number-limit 500)
  (helm-imenu-fuzzy-match t)
  (helm-buffer-max-length nil)
  (helm-move-to-line-cycle-in-source nil)
  (imenu-max-item-length 2000)
  (recentf-max-saved-items 2000)
  :bind
  ("C-x C-b" . helm-for-files)
  ("M-y" . helm-show-kill-ring)
  ("M-x" . helm-M-x)
  :config
  (add-to-list 'helm-completing-read-handlers-alist '(find-file . nil))
  (add-to-list 'helm-completing-read-handlers-alist '(write-file . nil))
  
  ;; Configure helm to ignore boring buffers  
  (add-to-list 'helm-boring-buffer-regexp-list "^*")
  (add-hook 'ido-make-buffer-list-hook
            (lambda () (let ((current (car (last ido-temp-list))))
                         (delq current ido-temp-list)
                         (push current ido-temp-list))))
  (advice-add 'helm-buffers-sort-transformer
              :override
              (lambda (candidates _source) candidates))

  ;; Face customizations
  (set-face-attribute 'helm-buffer-file nil :foreground "white")
  (set-face-attribute 'helm-ff-directory nil :foreground "DarkRed")
  (set-face-attribute 'helm-ff-dotted-directory nil :foreground "#8a8a8a")
  (set-face-attribute 'helm-ff-file nil :foreground "brightcyan")
  (set-face-attribute 'helm-header nil :inherit 'header-line :background "#1c1c1c" :underline nil)
  (set-face-attribute 'helm-helper nil :inherit 'helm-header :background "#121212" :underline nil)
  (set-face-attribute 'helm-selection nil :background "#000087" :underline t)
  (set-face-attribute 'helm-source-header nil :inherit 'header-line :underline nil))
