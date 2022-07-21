;; Clipper integration for tmux
(use-package emacs
  :bind
  ("C-M-w" . copy-clipper)
  :config
  (defun copy-clipper ()
    "Copies to Clipper"
    (interactive)
    (shell-command-on-region (region-beginning) (region-end) "tmux-nc localhost 8377")
    (message "Copied to Clipper")
    (deactivate-mark)))
