(use-package protobuf-mode
  :config
  (defconst protobuf-style
    '((c-basic-offset . 2)
      (indent-tabs-mode . nil)))
  :hook
  (protobuf-mode . (lambda () (c-add-style "my-style" protobuf-style t))))
