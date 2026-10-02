;; extends

; VS Code scopes round and square brackets as meta.brace, which the theme leaves at the
; editor foreground, while braces are punctuation.definition.block.
["(" ")"] @punctuation.bracket.round
["[" "]"] @punctuation.bracket.square

; Parameter list parentheses and destructuring brackets are punctuation.definition.*.
(formal_parameters ["(" ")"] @punctuation.bracket.parameters)
(array_pattern ["[" "]"] @punctuation.bracket.pattern)

; Object literal keys are meta.object-literal.key, which no rule colors.
(pair key: (property_identifier) @variable.member.key)

; Quote marks are punctuation.definition.string in every bundled grammar.
(string ["\"" "'"] @punctuation.delimiter.string)
(template_string "`" @punctuation.delimiter.string)

; The theme's `meta.block variable.other` rule: variables inside statement blocks,
; class bodies and import lists. Function names, constructors and parameters keep
; their own scopes in TextMate, so they are excluded.
((identifier) @variable.block
  (#has-ancestor? @variable.block statement_block class_body named_imports export_clause)
  (#not-has-parent? @variable.block call_expression new_expression function_declaration generator_function_declaration method_definition class_declaration formal_parameters assignment_pattern arrow_function required_parameter optional_parameter))

((member_expression property: (property_identifier) @variable.block)
  (#has-ancestor? @variable.block statement_block class_body))

(call_expression function: (member_expression property: (property_identifier) @function.method.call))
