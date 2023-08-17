;; extends
(type_declaration
    (type_spec (type_identifier) (struct_type (field_declaration_list (_)?) @customtype.inner))) @customtype.outer

(type_declaration
  (type_spec (type_identifier) (interface_type) @customtype.inner)) @customtype.outer
