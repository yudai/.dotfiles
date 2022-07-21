(use-package whitespace
  :init
  (global-whitespace-mode 1)
  :custom
  (whitespace-style '(face tabs tab-mark spaces lines-tail trailing empty))
  (whitespace-space-regexp "\\(\x3000+\\)")
  (whitespace-display-mappings '((tab-mark ?\t [?\xBB ?\t] [?\\ ?\t]))))

(custom-set-faces
 '(whitespace-line ((t (:background "#5f0000" :foreground nil))))
 '(whitespace-space ((t (:background "LightSlateGray"))))
 '(whitespace-tab ((t (:foreground "LightSlateGray" :underline t))))
 '(whitespace-trailing ((t (:background "DarkRed")))))
