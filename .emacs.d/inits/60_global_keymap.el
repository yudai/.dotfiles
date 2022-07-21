;; Global key bindings
(use-package emacs
  :bind
  ;; Basic editing
  ("C-h" . delete-backward-char)
  ("C-x C-t" . indent-region)
  ("M-g" . goto-line)
  ("C-^" . enlarge-window)
  ("C-]" . ignore)
  ("C-x 6 6" . toggle-truncate-lines)
  
  ;; Window management
  ("C-M-o" . other-window)
  ("C-x M-1" . balance-windows)
  
  ;; Window movement (windmove)
  ("C-M-k" . windmove-up)
  ("C-M-j" . windmove-down)
  ("C-M-l" . windmove-right)
  ("C-M-h" . windmove-left)
  ("C-x C-k" . windmove-up)
  ("C-x C-j" . windmove-down)
  ("C-x C-l" . windmove-right)
  ("C-x C-h" . windmove-left)
  
  ;; Buffer switching
  ("M-o" . bs-cycle-next)
  ("M-p" . bs-cycle-previous))
