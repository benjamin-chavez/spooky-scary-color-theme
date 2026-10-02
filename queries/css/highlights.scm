;; extends

(string_value ["\"" "'"] @spooky.punctuation)
(color_value) @spooky.punctuation

((charset_statement (string_value) @spooky.plain)
  (#set! priority 110))
((keyframe_block [(integer_value) (float_value)] @spooky.plain)
  (#set! priority 110))
(keyframes_name) @spooky.string

((plain_value) @spooky.string
  (#not-lua-match? @spooky.string "^%-%-"))
