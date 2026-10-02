;; extends

(string ["\"" "'" "[[" "]]"] @spooky.punctuation)
(parameters ["(" ")" ","] @spooky.punctuation)
(label_statement "::" @spooky.punctuation)
["in" "goto"] @spooky.punctuation

(method_index_expression table: (identifier) @spooky.type)
(function_declaration name: (dot_index_expression table: (identifier) @spooky.function))

((dot_index_expression table: (identifier) @_library "." @spooky.function)
  (#any-of? @_library "_G" "debug" "io" "jit" "math" "os" "package" "string" "table" "utf8" "coroutine"))
