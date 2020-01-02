(require 'lsp-mode)
(require 'lsp-yaml)
(setq lsp-yaml-schemas '(("file:///home/yudai/repos/liquid/goten/schemas/api-skeleton.schema.json" . "*")))
(add-hook 'yaml-mode-hook #'lsp)
