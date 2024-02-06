; extends
; boolean operator
(boolean_operator left: (_) @binary.lhs right: (_) @binary.rhs) @binary.outer

; boolean value
(true) @boolean
(false) @boolean

; dictionary
(dictionary) @dictionary.outer
(dictionary_comprehension) @dictionary.outer

; list
(list_comprehension) @list.outer
(list) @list.outer

; string
(string _ (string_content) @string.inner _) @string.outer
