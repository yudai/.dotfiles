(setq load-path (cons "~/.site-lisp/" load-path))
(if (eq emacs-major-version '21) (load "~/.emacs.21"))
(if (eq emacs-major-version '22) (load "~/.emacs.22"))
(if (eq emacs-major-version '23) (load "~/.emacs.23"))
(if (eq emacs-major-version '24) (load "~/.emacs.24"))
;;; Environment
(set-language-environment "japanese")
(prefer-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)


;;; etc
(setq-default indent-tabs-mode nil)
(temp-buffer-resize-mode 1)


;;; ispell
;;; http://blog.binchen.org/posts/what-s-the-best-spell-check-set-up-in-emacs.html
(defun flyspell-detect-ispell-args (&optional RUN-TOGETHER)
  "if RUN-TOGETHER is true, spell check the CamelCase words"
  (let (args)
    (cond
     ((string-match  "aspell$" ispell-program-name)
      ;; force the English dictionary, support Camel Case spelling check (tested with aspell 0.6)
      (setq args (list "--sug-mode=ultra" "--lang=en_US"))
      (if RUN-TOGETHER
          (setq args (append args '("--run-together" "--run-together-limit=5" "--run-together-min=2")))))
     ((string-match "hunspell$" ispell-program-name)
      (setq args nil)))
    args
    ))
(cond
 ((executable-find "aspell")
  (setq ispell-program-name "aspell"))
 ((executable-find "hunspell")
  (setq ispell-program-name "hunspell")
  ;; just reset dictionary to the safe one "en_US" for hunspell.
  ;; if we need use different dictionary, we specify it in command line arguments
  (setq ispell-local-dictionary "en_US")
  (setq ispell-local-dictionary-alist
        '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8))))
 (t (setq ispell-program-name nil)))

;; ispell-cmd-args is useless, it's the list of *extra* arguments we will append to the ispell process when "ispell-word" is called.
;; ispell-extra-args is the command arguments which will *always* be used when start ispell process
(setq ispell-extra-args (flyspell-detect-ispell-args t))
;; (setq ispell-cmd-args (flyspell-detect-ispell-args))
(defadvice ispell-word (around my-ispell-word activate)
  (let ((old-ispell-extra-args ispell-extra-args))
    (ispell-kill-ispell t)
    (setq ispell-extra-args (flyspell-detect-ispell-args))
    ad-do-it
    (setq ispell-extra-args old-ispell-extra-args)
    (ispell-kill-ispell t)
    ))
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-mode)

;;; Colors
(require 'color-theme)
(color-theme-initialize)
(color-theme-tty-dark)
(if window-system (set-face-background 'default "black"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(minibuffer-prompt ((t (:foreground "brightcyan")))))

;;; Keymaps
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\C-x t" 'indent-region)
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-^" 'enlarge-window)
(global-set-key "\C-x\C-a" 'switch-to-other-buffer)
(global-set-key "\C-]" 'ignore)

(defun switch-to-other-buffer () (interactive) (switch-to-buffer (other-buffer)))


;;; Moving over the windows
(windmove-default-keybindings)
;(setq windmove-wrap-around t)

;;; key-chord
(require 'key-chord)
(setq key-chord-two-keys-delay 0.08)
;(key-chord-mode 1)
(key-chord-define-global "ji" 'windmove-right)
(key-chord-define-global "fj" 'windmove-down)
(key-chord-define-global "fe" 'windmove-left)
(key-chord-define-global "ei" 'windmove-up)
(setq windmove-wrap-around t)
(define-key global-map (kbd "C-M-k") 'windmove-up)
(define-key global-map (kbd "C-M-j") 'windmove-down)
(define-key global-map (kbd "C-M-l") 'windmove-right)
(define-key global-map (kbd "C-M-h") 'windmove-left)



;;; Disable Backup
(setq make-backup-files nil)

;;; Mode line
(setq column-number-mode t)
(global-font-lock-mode t)

;;; Display
(setq show-paren-delay 0) ; paren
(show-paren-mode t)
(setq show-paren-style 'mixed)
;(global-hl-line-mode t) ;highline current line
(transient-mark-mode t) ; region highlight


(when (or window-system (eq emacs-major-version '21))
  (setq font-lock-support-mode
        (if (fboundp 'jit-lock-mode) 'jit-lock-mode 'lazy-lock-mode))
  (global-font-lock-mode t))

;;; *scratch*
(setq inhibit-startup-message t)
(setq initial-scratch-message "")


;;; minibuf-isearch
(require 'minibuf-isearch)

;;; redo
(require 'redo)
(global-set-key (kbd "C-.") 'redo)
(global-set-key (kbd "C-'") 'redo)
(global-set-key (kbd "C-M-_") 'redo)
(global-set-key (kbd "C-x C-_") 'redo)

;; auto-complete-mode
(require 'auto-complete-config)
(ac-config-default)
(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)
(define-key ac-completing-map [return] nil)
(define-key ac-completing-map "\r" nil)
(setq ac-use-comphist nil)

;;; applescript-mode
;(require 'applescript-mode)

;;; shell-mode
(autoload 'ansi-color-for-comint-mode-on "ansi-color"
   "Set `ansi-color-for-comint-mode' to t." t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;; ada-mode
(require 'align)
(setq ada-when-indent 0)
(setq ada-label-indent 0)



;;; javascript-mode
(when (load "js2" t)
  (add-to-list 'auto-mode-alist (cons  "\\.\\(js\\|as\\)\\'" 'js2-mode))
  (defun indent-and-back-to-indentation ()
  (interactive)
  (indent-for-tab-command)
  (let ((point-of-indentation
         (save-excursion
           (back-to-indentation)
           (point))))
    (skip-chars-forward "\\s " point-of-indentation)))
  (setq js2-mirror-mode nil)
  (setq js2-basic-offset nil)
  (setq js2-use-font-lock-faces t)
  (define-key js2-mode-map "\C-i" 'indent-and-back-to-indentation)
  (define-key js2-mode-map "\C-j" 'js2-enter-key))

(add-hook 'js2-mode-hook
          '(lambda ()
             (setq js2-basic-offset 4)))
(defface js2-function-param-face
    '((t :foreground "cadet blue"))
    "Face used to highlight function parameters in javascript."
    :group 'js2-mode)

; fixing indentation
; refer to http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode
(autoload 'espresso-mode "espresso")

(defun my-js2-indent-function ()
  (interactive)
  (save-restriction
    (widen)
    (let* ((inhibit-point-motion-hooks t)
           (parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (espresso--proper-indentation parse-status))
           node)

      (save-excursion

        ;; I like to indent case and labels to half of the tab width
        (back-to-indentation)
        (if (looking-at "case\\s-")
            (setq indentation (+ indentation (/ espresso-indent-level 2))))

        ;; consecutive declarations in a var statement are nice if
        ;; properly aligned, i.e:
        ;;
        ;; var foo = "bar",
        ;;     bar = "foo";
        (setq node (js2-node-at-point))
        (when (and node
                   (= js2-NAME (js2-node-type node))
                   (= js2-VAR (js2-node-type (js2-node-parent node))))
          (setq indentation (+ 4 indentation))))

      (indent-line-to indentation)
      (when (> offset 0) (forward-char offset)))))

(defun my-indent-sexp ()
  (interactive)
  (save-restriction
    (save-excursion
      (widen)
      (let* ((inhibit-point-motion-hooks t)
             (parse-status (syntax-ppss (point)))
             (beg (nth 1 parse-status))
             (end-marker (make-marker))
             (end (progn (goto-char beg) (forward-list) (point)))
             (ovl (make-overlay beg end)))
        (set-marker end-marker end)
        (overlay-put ovl 'face 'highlight)
        (goto-char beg)
        (while (< (point) (marker-position end-marker))
          ;; don't reindent blank lines so we don't set the "buffer
          ;; modified" property for nothing
          (beginning-of-line)
          (unless (looking-at "\\s-*$")
            (indent-according-to-mode))
          (forward-line))
        (run-with-timer 0.5 nil '(lambda(ovl)
                                   (delete-overlay ovl)) ovl)))))

(defun my-js2-mode-hook ()
  (require 'espresso)
  (setq espresso-indent-level 4
        indent-tabs-mode nil
        c-basic-offset 4)
  (c-toggle-auto-state 0)
  (c-toggle-hungry-state 1)
  (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
  ; (define-key js2-mode-map [(meta control |)] 'cperl-lineup)
  (define-key js2-mode-map "\C-\M-\\"
    '(lambda()
       (interactive)
       (insert "/* -----[ ")
       (save-excursion
         (insert " ]----- */"))
       ))
  (define-key js2-mode-map "\C-m" 'newline-and-indent)
  ; (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
  ; (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
  (define-key js2-mode-map "\C-\M-q" 'my-indent-sexp)
  (if (featurep 'js2-highlight-vars)
      (js2-highlight-vars-mode))
  (message "My JS2 hook"))

(add-hook 'js2-mode-hook 'my-js2-mode-hook)


;;; popwin
(require 'popwin)
;(popwin-mode 1)


;;; go-mode
(require 'go-direx)
(require 'go-autocomplete)

(defun my-go-mode-hook ())
(add-hook 'go-mode-hook (lambda ()
                          (setq tab-width 2)
                          (set (make-local-variable 'whitespace-style) '(face trailing lines-tail empty))
                          'go-eldoc-setup
                          (local-set-key (kbd "M-.") 'godef-jump)
                          (local-set-key (kbd "C-c C-f") 'gofmt)
                          (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)
                          (local-set-key (kbd "C-c C-p") 'go-direx-pop-to-buffer)))

(push '(direx:direx-mode :position left :width 0.4 :dedicated t :stick t)
      popwin:special-display-config)

(add-hook 'before-save-hook 'gofmt-before-save)
;(setq gofmt-command "goimports")

;;; Rspec mode
(require 'rspec-mode)

;;; ruby-mode
(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(setq auto-mode-alist
      (append '(("Rakefile" . ruby-mode)) auto-mode-alist))
; pretty indent
; http://willnet.in/13
(setq ruby-deep-indent-paren-style nil)
(defadvice ruby-indent-line (after unindent-closing-paren activate)
  (let ((column (current-column))
        indent offset)
    (save-excursion
      (back-to-indentation)
      (let ((state (syntax-ppss)))
        (setq offset (- column (current-column)))
        (when (and (eq (char-after) ?\))
                   (not (zerop (car state))))
          (goto-char (cadr state))
          (setq indent (current-indentation)))))
    (when indent
      (indent-line-to indent)
      (when (> offset 0) (forward-char offset)))))


;;; css-mode
(add-to-list 'auto-mode-alist '("\\.css\\'" . css-mode))
(autoload 'css-mode "css-mode" nil t)

;;; highlit yanked area
(defadvice yank (after ys:highlight-string activate)
  (let ((ol (make-overlay (mark t) (point))))
    (overlay-put ol 'face 'bold)
    (sit-for 0.8)
    (delete-overlay ol)))
(defadvice yank-pop (after ys:highlight-string activate)
  (when (eq last-command 'yank)
    (let ((ol (make-overlay (mark t) (point))))
      (overlay-put ol 'face 'bold)
      (sit-for 0.8)
      (delete-overlay ol))))

;;; delete region
(defadvice backward-delete-char-untabify
  (around ys:backward-delete-region activate)
  (if (and transient-mark-mode mark-active)
      (delete-region (region-beginning) (region-end))
    ad-do-it))

;;; session minibuffer
(when (require 'session nil t)
  (setq session-initialize '(de-saveplace session keys menus)
        session-globals-include '((kill-ring 50)
                                  (session-file-alist 100 t)
                                  (file-name-history 100)))
  (add-hook 'after-init-hook 'session-initialize))

;;; hide menubar in -nw
(menu-bar-mode -1)


;;; minibuffer
(define-key minibuffer-local-must-match-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-must-match-map "\C-n" 'next-history-element)
(define-key minibuffer-local-completion-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-completion-map "\C-n" 'next-history-element)
(define-key minibuffer-local-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-map "\C-n" 'next-history-element)

;;; browse kill ring
(require 'browse-kill-ring)
(define-key ctl-x-map "\C-y" 'browse-kill-ring)

; shows character codes
(require 'what-char)

; buffer list
(global-set-key "\C-x\C-b" 'bs-show)
(global-set-key "\M-o" 'bs-cycle-next)
(global-set-key "\M-p" 'bs-cycle-previous)



(defface my-face-b-1 '((t (:background "red" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("　" 0 my-face-b-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
(if font-lock-mode nil
  (font-lock-mode t))) t)

(require 'whitespace)
(global-whitespace-mode t)
(setq whitespace-style '(face tabs lines-tail trailing empty))
(set-face-underline  'whitespace-trailing t)
(set-face-foreground 'whitespace-trailing "red")
(set-face-background 'whitespace-trailing "DarkRed")
(set-face-foreground 'whitespace-tab "LightSlateGray")
(set-face-background 'whitespace-tab "DarkSlateGray")

; incremental search in buffer selection
(iswitchb-mode 1)
(add-hook 'iswitchb-define-mode-map-hook
      (lambda ()
        (define-key iswitchb-mode-map "\C-n" 'iswitchb-next-match)
        (define-key iswitchb-mode-map "\C-p" 'iswitchb-prev-match)
        (define-key iswitchb-mode-map "\C-f" 'iswitchb-next-match)
        (define-key iswitchb-mode-map "\C-b" 'iswitchb-prev-match)))

; trucate
(require 'physical-line)
(physical-line-mode nil)
(setq-default auto-show-mode t)
(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)
(defun toggle-truncate-lines ()
  "toggle trucate lines"
  (interactive)
  (setq truncate-lines (not truncate-lines))
  (physical-line-mode)
  (recenter))
(global-set-key (kbd "\C-x 6 6") 'toggle-truncate-lines)


; W3CDTF
(defun get-w3cdtf-now ()
  (interactive)
  (insert (format-time-string "%Y-%m-%dT%H:%M:%S+09:00")))
(global-set-key "\C-xt3" 'get-w3cdtf-now)
(defun get-w3cdtf-z-now ()
  (interactive)
  (insert (format-time-string "%Y-%m-%dT%H:%M:%SZ" t)))
(global-set-key "\C-xt4" 'get-w3cdtf-z-now)

; xml-mode
(load "nxml-mode/rng-auto.el")
(setq auto-mode-alist
        (cons '("\\.\\(xnm\\|xml\\|xsl\\|rng\\|xhtml\\)\\'" . nxml-mode)
              auto-mode-alist))


; CSS Bullet
(setq reload-path "~/bin/reload_cssbullet")
(if (file-executable-p reload-path)
    (progn (defun reload-cssbullet()
             (if (string-match "\.\\(html\\|css\\|js\\)$" (buffer-file-name))
                 (call-process reload-path)))
           (add-hook 'after-save-hook 'reload-cssbullet)))

; scala mode
(require 'scala-mode-auto)
(add-hook 'scala-mode-hook
          '(lambda ()
             (yas/minor-mode-on)))


;; gnu global
(autoload 'gtags-mode "gtags" "" t)
(setq gtags-mode-hook
      '(lambda ()
         (local-set-key "\M-t" 'gtags-find-tag)
         (local-set-key "\M-r" 'gtags-find-rtag)
         (local-set-key "\M-s" 'gtags-find-symbol)
         (local-set-key "\C-t" 'gtags-pop-stack)
         ))

;;; yaml
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))


;;; markdown
(autoload 'markdown-mode "markdown-mode.el" "Major mode for editing Markdown files" t)
(setq auto-mode-alist (cons '("\\.md" . markdown-mode) auto-mode-alist))

;;; php-mode
(require 'php-mode)
(add-hook 'php-mode-hook
          '(lambda ()
             (setq c-basic-offset 2)))

;;; Flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)
