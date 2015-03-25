(zlc-mode 1)
(let ((map minibuffer-local-map))
  (define-key map (kbd "<down>")  'zlc-select-next-vertical)
  (define-key map (kbd "<up>")    'zlc-select-previous-vertical)
  (define-key map (kbd "<right>") 'zlc-select-next)
  (define-key map (kbd "<left>")  'zlc-select-previous)
  (define-key map (kbd "M-<tab>") 'zlc-select-previous)
  (define-key map (kbd "M-TAB") 'zlc-select-previous)
  (define-key map (kbd "C-c") 'zlc-reset)
)

;;; Ignore .. and .
(add-to-list 'completion-ignored-extensions ".")
(add-to-list 'completion-ignored-extensions "..")
(advice-add 'completion-file-name-table
            :filter-return
            (lambda (r)
              (if (and (listp r)
                       (stringp (car r))
                       (cdr r))
                  (completion-pcm--filename-try-filter r)
                r)))

(setq read-file-name-completion-ignore-case t)
