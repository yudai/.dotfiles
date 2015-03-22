(add-to-list 'custom-theme-load-path
             (file-name-as-directory "~/.emacs.d/lisp/"))
(load-theme 'tty-dark t)

(set-face-attribute 'highlight nil :background "color-18" :foreground "yellow")
(set-face-attribute 'isearch-fail nil :background "color-181" :foreground "black")
(set-face-attribute 'lazy-highlight nil :background "paleturquoise" :foreground "black")
(set-face-attribute 'match nil :foreground "color-51")
(set-face-attribute 'minibuffer-prompt nil :foreground "brightcyan")
(set-face-attribute 'mode-line nil :background "color-239" :foreground "color-214")
(set-face-attribute 'mode-line-buffer-id nil :background "color-236" :foreground "red")
(set-face-attribute 'mode-line-inactive nil :inherit 'mode-line :background "color-236" :foreground "color-233")
