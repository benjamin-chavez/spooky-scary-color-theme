;; extends

(string_value ["\"" "'"] @punctuation.delimiter.string)

; constant.other.color is listed under the Operator, Misc rule, so hex colors are grey.
(color_value) @string.color
