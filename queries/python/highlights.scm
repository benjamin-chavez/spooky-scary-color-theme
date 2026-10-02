;; extends

(string (string_start) @punctuation.delimiter.string)
(string (string_end) @punctuation.delimiter.string)

; The return annotation arrow is punctuation.separator.annotation.result.
(function_definition "->" @punctuation.delimiter.annotation)

; meta.function-call colors otherwise unscoped names inside call arguments.
((identifier) @variable.argument
  (#has-ancestor? @variable.argument argument_list generator_expression)
  (#not-has-parent? @variable.argument keyword_argument))
