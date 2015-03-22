(add-hook 'after-init-hook 'session-initialize)
(setq history-length 200)
(setq session-initialize '(de-saveplace session keys menus))
(setq session-globals-include
      '((kill-ring 200) (session-file-alist 200 t) (file-name-history 200)))
(setq session-save-file "~/.emacs_session")
