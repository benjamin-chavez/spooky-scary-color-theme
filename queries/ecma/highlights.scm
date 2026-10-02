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

; Capitalized identifiers in value positions are plain variables in TextMate; the
; nvim-treesitter query guesses they are types.
((identifier) @variable.capitalized
  (#lua-match? @variable.capitalized "^[A-Z]")
  (#not-has-parent? @variable.capitalized class_declaration class_heritage extends_clause new_expression call_expression enum_declaration function_declaration generator_function_declaration function_expression))

; Inherited classes are entity.other.inherited-class, the constructor method is
; storage.type, and `in`/`of` in loops are keyword.operator.expression.
(method_definition name: (property_identifier) @constructor.keyword
  (#eq? @constructor.keyword "constructor"))
(for_in_statement ["in" "of"] @keyword.operator)
(await_expression "await" @keyword.coroutine.await)
(export_statement "default" @keyword.default)

; The theme's `meta.block variable.other` rule: variables inside statement blocks,
; class bodies and import lists. Function names, constructors and parameters keep
; their own scopes in TextMate, so they are excluded.
((identifier) @variable.block
  (#has-ancestor? @variable.block statement_block class_body named_imports export_clause)
  (#not-has-parent? @variable.block call_expression new_expression function_declaration generator_function_declaration method_definition class_declaration formal_parameters assignment_pattern arrow_function required_parameter optional_parameter))

((member_expression property: (property_identifier) @variable.block)
  (#has-ancestor? @variable.block statement_block class_body))

(call_expression function: (member_expression property: (property_identifier) @function.method.call))
