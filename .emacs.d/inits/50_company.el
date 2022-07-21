(use-package company
  :hook (after-init . global-company-mode)
  :bind
  ("TAB" . company-indent-or-complete-common)
  :bind (:map company-active-map
              ("TAB" . (lambda () (interactive) (company-complete-common-or-cycle 1)))
              ("<backtab>" . (lambda () (interactive) (company-complete-common-or-cycle -1)))
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)
              ("C-h" . nil)
              ("C-s" . company-filter-candidates))
  :bind (:map company-search-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous))
  :custom
  (company-tooltip-limit 20)
  (company-idle-delay nil)
  (company-echo-delay 0)
  (company-begin-commands '(self-insert-command))
  (company-dabbrev-downcase nil)
  (company-tooltip-align-annotations t))

(custom-set-faces
 '(company-preview
   ((t (:foreground "darkgray" :underline t))))
 '(company-preview-common
   ((t (:inherit company-preview))))
 '(company-tooltip
   ((t (:background "lightgray" :foreground "black"))))
 '(company-tooltip-selection
   ((t (:background "steelblue" :foreground "white"))))
 '(company-tooltip-common
   ((((type x)) (:inherit company-tooltip :weight bold))
    (t (:inherit company-tooltip))))
 '(company-tooltip-common-selection
   ((((type x)) (:inherit company-tooltip-selection :weight bold))
    (t (:inherit company-tooltip-selection)))))
