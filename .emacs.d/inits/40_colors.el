(add-to-list 'custom-theme-load-path
             (file-name-as-directory "~/.emacs.d/lisp/"))
(load-theme 'tty-dark t)

(custom-set-faces
 '(highlight ((t (:background "color-18" :foreground "yellow"))))
 '(isearch-fail ((t (:background "color-181" :foreground "black"))))
 '(lazy-highlight ((t (:background "paleturquoise" :foreground "black"))))
 '(match ((t (:foreground "color-51"))))
 '(minibuffer-prompt ((t (:foreground "brightcyan"))))
 '(mode-line ((t (:background "color-239" :foreground "color-214"))))
 '(mode-line-buffer-id ((t (:background "color-236" :foreground "red"))))
 '(mode-line-inactive ((t (:inherit 'mode-line :background "color-236" :foreground "color-233"))))
 '(region ((t (:inverse-video t :foreground nil :background nil))))
 '(show-paren-match ((t (:inverse-video t :foreground nil :background nil))))
 '(whitespace-trailing ((t (:background "DarkRed"))))
 '(whitespace-space ((t (:background "LightSlateGray"))))
 '(whitespace-tab ((t (:foreground "LightSlateGray" :underline t))))
 '(whitespace-line ((t (:background "gray20" :foreground nil))))
 '(flyspell-incorrect ((t (:underline t))))
 '(flyspell-duplicate ((t (:underline t))))
 '(flycheck-warning ((t (:inherit nil))))
 '(flycheck-error ((t (:underline t :foreground "orange"))))
 '(flycheck-warning ((t (:inherit nil)))))