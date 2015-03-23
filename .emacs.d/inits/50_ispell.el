(require 'ispell)
(setq ispell-extra-args '("-a" "-m" "--run-together" "--run-together-limit=5" "--run-together-min=2" "--sug-mode=ultra"))
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-mode)
