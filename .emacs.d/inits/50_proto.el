(defconst protobuf-style
  '((c-basic-offset . 4)
    (indent-tabs-mode . nil)))

(add-hook 'protobuf-mode-hook
  (lambda () (c-add-style "my-style" protobuf-style t)))
