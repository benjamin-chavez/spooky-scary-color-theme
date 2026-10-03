;; extends

["{" "}"] @spooky.punctuation
(formal_parameters ["(" ")"] @spooky.punctuation)
(array_pattern ["[" "]"] @spooky.punctuation)

(pair key: (property_identifier) @spooky.plain)
(string ["\"" "'"] @spooky.punctuation)
(template_string "`" @spooky.punctuation)
(regex "/" @spooky.punctuation)
(hash_bang_line) @spooky.comment
"break" @spooky.punctuation
"debugger" @spooky.keyword.other
(decorator "@" @spooky.punctuation)

((identifier) @spooky.variable
  (#lua-match? @spooky.variable "^[A-Z]")
  (#not-has-parent? @spooky.variable class_declaration class_heritage extends_clause new_expression call_expression enum_declaration function_declaration generator_function_declaration function_expression))

[(this) (super)] @spooky.variable.language

(method_definition name: (property_identifier) @spooky.keyword
  (#eq? @spooky.keyword "constructor"))
(for_in_statement ["in" "of"] @spooky.keyword)
(await_expression "await" @spooky.punctuation)
(export_statement "default" @spooky.punctuation)

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

((arguments ["(" ")"] @spooky.punctuation)
  (#has-ancestor? @spooky.punctuation jsx_expression))
