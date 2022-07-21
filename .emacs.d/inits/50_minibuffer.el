;; Minibuffer navigation improvements
(use-package emacs
  :bind (:map minibuffer-local-must-match-map
              ("C-p" . previous-history-element)
              ("C-n" . next-history-element))
  :bind (:map minibuffer-local-completion-map
              ("C-p" . previous-history-element)
              ("C-n" . next-history-element))
  :bind (:map minibuffer-local-map
              ("C-p" . previous-history-element)
              ("C-n" . next-history-element)))
