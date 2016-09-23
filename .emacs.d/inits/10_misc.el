(menu-bar-mode -1)
(tool-bar-mode -1)
(set-display-table-slot (setq standard-display-table
                              (make-display-table))
                        'vertical-border ?│)

;;; paren
(show-paren-mode t)
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)

;;; undo-tree
(global-undo-tree-mode)

;;; W3C DTF daytime
(defun get-w3cdtf-z-now ()
  (interactive)
  (insert (format-time-string "%Y-%m-%dT%H:%M:%SZ" t)))
(define-key global-map (kbd "C-x t 4") 'get-w3cdtf-z-now)
