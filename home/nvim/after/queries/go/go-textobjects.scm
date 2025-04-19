;; extends

; add variadic_parameter_declaration
(parameter_list
  .
  (variadic_parameter_declaration) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

; peeking should show the body of functions and types
[ (type_declaration) (function_declaration) (method_declaration) ] @peek

; struct and interface declaration as customtype textobject
(type_declaration
  (type_spec
    (type_identifier)
    (struct_type))) @customtype.outer

(type_declaration
  (type_spec
    (type_identifier)
    (struct_type
      (field_declaration_list
        "{"
        .
        _ @_start @_end
        _? @_end
        .
        "}"
        (#make-range! "customtype.inner" @_start @_end)))))

(type_declaration
  (type_spec
    (type_identifier)
    (interface_type))) @customtype.outer

(type_declaration
  (type_spec
    (type_identifier)
    (interface_type
      "{"
      .
      _ @_start @_end
      _? @_end
      .
      "}"
      (#make-range! "customtype.inner" @_start @_end))))
