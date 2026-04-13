;; extends

; ; standalone variadic parameter
; (parameter_list
;   ("," @_start
;   .)?
;   (variadic_parameter_declaration) @parameter.inner
;   (#make-range! "parameter.outer" @_start @parameter.inner))

(function_declaration (identifier)  @function.name)
(method_declaration (field_identifier)  @function.name)

(
	((comment)*) @doc
	.
	(method_declaration) @def
) @function.all

(
	((comment)*) @doc
	.
	(function_declaration) @def
) @function.all
