;; extends

; Type annotation punctuation is keyword.operator.type in TextMate, so it takes the keyword color.
(type_annotation ":" @punctuation.delimiter.type)
(union_type "|" @punctuation.delimiter.type)
(intersection_type "&" @punctuation.delimiter.type)
(optional_parameter "?" @punctuation.delimiter.type)
(property_signature "?" @punctuation.delimiter.type)
