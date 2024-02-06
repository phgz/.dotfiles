; extends
; binary expression
(binary_expression left: (_) @binary.lhs right: (_) @binary.rhs) @binary.outer

; boolean value
(true) @boolean
(false) @boolean

; table
(table_constructor) @dictionary.outer @list.outer

; string
(string _ (string_content) @string.inner _) @string.outer
