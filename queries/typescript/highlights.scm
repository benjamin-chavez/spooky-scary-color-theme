;; extends

; Type annotation punctuation is keyword.operator.type in TextMate, so it takes the keyword color.
(type_annotation ":" @punctuation.delimiter.type)
(union_type "|" @punctuation.delimiter.type)
(intersection_type "&" @punctuation.delimiter.type)
(optional_parameter "?" @punctuation.delimiter.type)
(property_signature "?" @punctuation.delimiter.type)

; `import type` is keyword.control.type; implemented and extended types are inherited classes.
(import_statement "type" @keyword.import.type)
(implements_clause (type_identifier) @type.inherited)
(implements_clause (generic_type (type_identifier) @type.inherited))
(extends_clause value: (identifier) @type.inherited)

(formal_parameters ["(" ")"] @punctuation.bracket.parameters)

; The typescript base query loads after the ecma extension and re-captures capitalized
; identifiers as types, so the identifier rules from queries/ecma are repeated here.
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
