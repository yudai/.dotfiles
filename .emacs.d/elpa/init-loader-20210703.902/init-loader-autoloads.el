;;; init-loader-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "init-loader" "init-loader.el" (0 0 0 0))
;;; Generated autoloads from init-loader.el

(autoload 'init-loader-load "init-loader" "\
Load configuration files in INIT-DIR.

\(fn &optional (INIT-DIR init-loader-directory))" nil nil)

(autoload 'init-loader-show-log "init-loader" "\
Show init-loader log buffer." t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "init-loader" '("init-loader-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; init-loader-autoloads.el ends here
