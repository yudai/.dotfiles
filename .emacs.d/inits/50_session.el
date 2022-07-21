(use-package session
  :hook (after-init . session-initialize)
  :custom
  (history-length 200)
  (session-initialize '(de-saveplace session keys menus))
  (session-globals-include
   '((kill-ring 200) (session-file-alist 200 t) (file-name-history 200)))
  (session-save-file "~/.emacs_session")
  (session-save-print-spec '(t nil 40000))
  (session-use-package t))
