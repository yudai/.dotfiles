(menu-bar-mode -1)
(tool-bar-mode -1)
(set-display-table-slot (setq standard-display-table
                              (make-display-table))
                        'vertical-border ?│)

;;; paren
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)

;;; undo-tree
(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode)
  :bind ("C-x u" . undo-tree-visualize)
  :bind (:map undo-tree-visualizer-mode-map
              ("C-g" . undo-tree-visualizer-quit)))

;;; W3C DTF daytime
(defun get-w3cdtf-z-now ()
  (interactive)
  (insert (format-time-string "%Y-%m-%dT%H:%M:%SZ" t)))
(define-key global-map (kbd "C-x t 4") 'get-w3cdtf-z-now)
