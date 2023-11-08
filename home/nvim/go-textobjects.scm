;; extends

; custom blocks without curlies
(_
  (block . "{" . (_) @_start (_)? @_end . "}" (#make-range! "customblock.inner" @_start @_end)))

(if_statement
  (block . "{" . (_) @_start (_)? @_end . "}" (#make-range! "customconditional.inner" @_start @_end)))

(for_statement
  (block . "{" . (_) @_start (_)? @_end . "}" (#make-range! "customloop.inner" @_start @_end)))

; custom go type (@class includes literals?!)
(type_declaration) @customtype.outer

; peeking should show the body of functions and types
[ (type_declaration) (function_declaration) (method_declaration) ] @peek

; custom go type bodies without curlies
(type_declaration
  (type_spec 
    name: (type_identifier)
    type: [
    	(struct_type (field_declaration_list . "{" . (_) @_start @_end (_)? @_end . "}"))
        (interface_type . "{" . (_) @_start @_end (_)? @_end . "}")
    ]
    (#make-range! "customtype.inner" @_start @_end)
  )
)
