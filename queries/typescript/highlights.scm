;; extends

(type_annotation ":" @spooky.keyword)
(union_type "|" @spooky.keyword)
(intersection_type "&" @spooky.keyword)
(optional_parameter "?" @spooky.keyword)
(property_signature "?" @spooky.keyword)
[(type_arguments ["<" ">"] @spooky.punctuation)
 (type_parameters ["<" ">"] @spooky.punctuation)]

(import_statement "type" @spooky.punctuation)
(implements_clause (type_identifier) @spooky.string)
(implements_clause (generic_type (type_identifier) @spooky.string))
(extends_clause value: (identifier) @spooky.string)
(this_type) @spooky.type.builtin
(formal_parameters ["(" ")"] @spooky.punctuation)

; TypeScript's base query follows ecma and repeats its identifier heuristics.
((identifier) @spooky.variable
  (#lua-match? @spooky.variable "^[A-Z]")
  (#not-has-parent? @spooky.variable class_declaration class_heritage extends_clause new_expression call_expression enum_declaration function_declaration generator_function_declaration function_expression))

(method_definition name: (property_identifier) @spooky.keyword
  (#eq? @spooky.keyword "constructor"))

((identifier) @spooky.variable.block
  (#has-ancestor? @spooky.variable.block statement_block named_imports export_clause)
  (#not-has-parent? @spooky.variable.block call_expression new_expression function_declaration generator_function_declaration method_definition class_declaration formal_parameters assignment_pattern arrow_function required_parameter optional_parameter))

((member_expression property: (property_identifier) @spooky.variable.block)
  (#has-ancestor? @spooky.variable.block statement_block))

(call_expression function: (member_expression property: (property_identifier) @spooky.function))
(variable_declarator name: (identifier) @spooky.function value: [(arrow_function) (function_expression)])
(assignment_expression left: (identifier) @spooky.function right: [(arrow_function) (function_expression)])

((identifier) @spooky.variable.language
  (#eq? @spooky.variable.language "arguments")
  (#not-has-parent? @spooky.variable.language formal_parameters required_parameter optional_parameter))

((member_expression property: (property_identifier) @spooky.plain)
  (#eq? @spooky.plain "length"))
