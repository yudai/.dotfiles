(require 'helm-config)
(helm-mode 1)
(setq helm-truncate-lines t)
(setq helm-candidate-number-limit 500)
(setq helm-imenu-fuzzy-match t)
(setq helm-buffer-max-length nil)

(add-to-list 'helm-completing-read-handlers-alist '(find-file . nil))
(add-to-list 'helm-completing-read-handlers-alist '(write-file . nil))

(define-key global-map (kbd "C-x C-b") 'helm-for-files)
(define-key global-map (kbd "M-y") 'helm-show-kill-ring)
(define-key global-map (kbd "M-x") 'helm-M-x)

(push '("^\\*helm.*\\*$" :height 0.3 :regexp t :position bottom) popwin:special-display-config)

(add-to-list 'helm-boring-buffer-regexp-list "^*")
(add-hook 'ido-make-buffer-list-hook
          (lambda () (let ((current (car (last ido-temp-list))))
                       (delq current ido-temp-list)
                       (push current ido-temp-list))))
(advice-add 'helm-buffers-sort-transformer
            :override
            (lambda (candidates _source) candidates))


;;; recentf
(setq recentf-max-saved-items 2000)

(set-face-attribute 'helm-buffer-file nil :foreground "white")
(set-face-attribute 'helm-ff-directory nil :foreground "DarkRed")
(set-face-attribute 'helm-ff-dotted-directory nil :foreground "#8a8a8a")
(set-face-attribute 'helm-ff-file nil :foreground "brightcyan")
(set-face-attribute 'helm-header nil :inherit 'header-line :background "#1c1c1c" :underline nil)
(set-face-attribute 'helm-helper nil :inherit 'helm-header :background "#121212" :underline nil)
(set-face-attribute 'helm-selection nil :background "#000087" :underline t)
(set-face-attribute 'helm-source-header nil :inherit 'header-line :underline nil)

(setq imenu-max-item-length 2000)
