(add-hook 'go-mode-hook
          (lambda ()
            (setq tab-width 2)
            (set (make-local-variable 'whitespace-style) '(face trailing lines-tail empty space))
            (go-eldoc-setup)
            (local-set-key (kbd "C-c C-o") 'godef-jump-other-window)
            (local-set-key (kbd "C-c C-j") 'godef-jump)
            (local-set-key (kbd "C-c C-a") '(lambda () (interactive) (go-import-add t (replace-regexp-in-string "^[\"']\\|[\"']$" "" (completing-read "Package: " (go--old-completion-list-style (go-packages)))))))
            (local-set-key (kbd "C-c C-f") 'gofmt)
            (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)
            (local-set-key (kbd "C-c C-p") 'go-direx-pop-to-buffer)))

(require 'popwin)
(push '(direx:direx-mode :position left :width 0.4 :dedicated t :stick nil)
      popwin:special-display-config)

(require 'go-autocomplete)

(add-hook 'before-save-hook 'gofmt-before-save)