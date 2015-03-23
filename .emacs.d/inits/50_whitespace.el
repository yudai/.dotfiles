(require 'whitespace)
(global-whitespace-mode t)

(setq whitespace-style
      '(face tabs tab-mark spaces lines-tail trailing empty))
(setq whitespace-space-regexp "\\(\x3000+\\)")
(setq whitespace-display-mappings '((tab-mark ?\t [?\xBB ?\t] [?\\ ?\t])))
