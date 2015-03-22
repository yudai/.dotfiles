(define-key global-map (kbd "C-h") 'delete-backward-char)
(define-key global-map (kbd "C-x C-t") 'indent-region)
(define-key global-map (kbd "M-g") 'goto-line)
(define-key global-map (kbd "C-^") 'enlarge-window)
(define-key global-map (kbd "C-]") 'ignore)
(define-key global-map (kbd "\C-x 6 6") 'toggle-truncate-lines)

(define-key global-map (kbd "C-M-o") 'other-window)
(define-key global-map (kbd "C-M-k") 'windmove-up)
(define-key global-map (kbd "C-M-j") 'windmove-down)
(define-key global-map (kbd "C-M-l") 'windmove-right)
(define-key global-map (kbd "C-M-h") 'windmove-left)

(define-key global-map (kbd "M-o") 'bs-cycle-next)
(define-key global-map (kbd "M-p") 'bs-cycle-previous)

