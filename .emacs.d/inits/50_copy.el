(defun copy-clipper ()
      "Copies to Clipper"
      (interactive)
      (shell-command-on-region (region-beginning) (region-end) "nc localhost 8377")
      (message "Copied to Clipper")
      (deactivate-mark))

(define-key global-map (kbd "C-M-w") 'copy-clipper)
