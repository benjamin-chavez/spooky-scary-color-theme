;; extends

(string (string_start) @spooky.punctuation)
(string (string_end) @spooky.punctuation)

((string (string_start) @_prefix (string_end) @spooky.string)
  (#lua-match? @_prefix "^[rRuUbB]*[fF]"))
((string_start) @spooky.string
  (#lua-match? @spooky.string "^[rRuUbB]*[fF]"))

((string_start) @spooky.string.prefix
  (#lua-match? @spooky.string.prefix "^%a+[\"']$")
  (#offset! @spooky.string.prefix 0 0 0 -1))
((string_start) @spooky.string.prefix
  (#lua-match? @spooky.string.prefix "^%a+[\"'][\"'][\"']$")
  (#offset! @spooky.string.prefix 0 0 0 -3))

(function_definition "->" @spooky.punctuation)
"async" @spooky.keyword

((identifier) @spooky.function
  (#has-ancestor? @spooky.function argument_list generator_expression)
  (#set! priority 99))

(class_definition superclasses: (argument_list (identifier) @spooky.string))
(class_definition name: (identifier) @spooky.type)

((decorator "@" @spooky.punctuation)
  (#set! priority 110))

((parameters (identifier) @spooky.parameter)
  (#any-of? @spooky.parameter "self" "cls"))

((identifier) @spooky.plain
  (#lua-match? @spooky.plain "^__[%w_]+__$")
  (#not-has-parent? @spooky.plain function_definition call attribute))

((for_in_clause "in" @spooky.punctuation)
  (#has-ancestor? @spooky.punctuation generator_expression list_comprehension set_comprehension dictionary_comprehension))
((comparison_operator ["is" "not" "is not" "not in"] @spooky.punctuation)
  (#has-ancestor? @spooky.punctuation generator_expression list_comprehension set_comprehension dictionary_comprehension)
  (#set! priority 110))

; Builtin types and exceptions are support.type in TextMate even when called.
((call function: (identifier) @spooky.type.builtin)
  (#any-of? @spooky.type.builtin "bool" "bytearray" "bytes" "classmethod" "complex" "dict"
    "float" "frozenset" "int" "list" "memoryview" "object" "property" "set" "slice"
    "staticmethod" "str" "super" "tuple" "type"))
((call function: (identifier) @spooky.type.builtin)
  (#lua-match? @spooky.type.builtin "^%u%w*Error$"))
((call function: (identifier) @spooky.type.builtin)
  (#lua-match? @spooky.type.builtin "^%u%w*Exception$"))
((call function: (identifier) @spooky.type.builtin)
  (#lua-match? @spooky.type.builtin "^%u%w*Warning$"))
((call function: (identifier) @spooky.type.builtin)
  (#any-of? @spooky.type.builtin "StopIteration" "StopAsyncIteration" "KeyboardInterrupt"
    "SystemExit" "GeneratorExit"))
