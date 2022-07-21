(prefer-coding-system 'utf-8-unix)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 8)

(setq-default line-number-mode t)
(setq-default column-number-mode t)

(setq-default make-backup-files nil)
(setq-default create-lockfiles nil)
(setq-default auto-save-file-name-transforms   '((".*" "~/.emacs.d/auto-save/" t)))

(setq-default inhibit-startup-message t)
(setq-default initial-scratch-message "")

(setq-default truncate-lines t)
(setq-default truncate-partial-width-windows nil)

(setq-default split-height-threshold nil)
(setq-default split-width-threshold 300)

(require 'use-package-ensure)
(setq use-package-always-ensure t)
(setq quelpa-update-melpa-p nil)
(use-package quelpa :ensure t)
(use-package quelpa-use-package
  :demand t
  :config
  (quelpa-use-package-activate-advice))
