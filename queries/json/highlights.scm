;; extends

"\"" @spooky.punctuation
(escape_sequence) @spooky.string.escape

((string (escape_sequence) @spooky.string.escape . (string_content) @_unicode_digits)
  (#eq? @spooky.string.escape "\\u")
  (#lua-match? @_unicode_digits "^%x%x%x%x")
  (#offset! @spooky.string.escape 0 0 0 4))

; The theme colors keys by how many objects enclose them. plugin/spooky-scary.lua defines
; the predicate; the last matching pattern wins, so deeper levels are listed later.
((pair key: (string) @spooky.json.key1) (#spooky-json-depth? @spooky.json.key1 1))
((pair key: (string) @spooky.json.key2) (#spooky-json-depth? @spooky.json.key2 2))
((pair key: (string) @spooky.json.key3) (#spooky-json-depth? @spooky.json.key3 3))
((pair key: (string) @spooky.json.key4) (#spooky-json-depth? @spooky.json.key4 4))
((pair key: (string) @spooky.json.key5) (#spooky-json-depth? @spooky.json.key5 5))
((pair key: (string) @spooky.json.key6) (#spooky-json-depth? @spooky.json.key6 6))
((pair key: (string) @spooky.json.key7) (#spooky-json-depth? @spooky.json.key7 7))
((pair key: (string) @spooky.json.key8) (#spooky-json-depth? @spooky.json.key8 8))
(pair key: (string "\"" @spooky.punctuation))
