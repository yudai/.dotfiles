(global-whitespace-mode t)

(setq whitespace-style
      '(face tabs tab-mark spaces lines-tail trailing empty))
(setq whitespace-space-regexp "\\(\x3000+\\)")
(setq whitespace-display-mappings '((tab-mark ?\t [?\xBB ?\t] [?\\ ?\t])))

(set-face-attribute 'whitespace-trailing nil :background "DarkRed")
(set-face-attribute 'whitespace-space nil :background "LightSlateGray")
(set-face-attribute 'whitespace-tab nil :foreground "LightSlateGray" :underline t)
