(use-package locate
  :defer t
  :init
  ;; Use Spotlight on macOS when available.
  (when (and (eq system-type 'darwin)
             (executable-find "mdfind"))
    (setq locate-command "mdfind")))
