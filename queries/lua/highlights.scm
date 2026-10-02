;; extends

(string ["\"" "'" "[[" "]]"] @punctuation.delimiter.string)
(parameters ["(" ")"] @punctuation.bracket.parameters)
(parameters "," @punctuation.delimiter.parameters)
(label_statement "::" @punctuation.delimiter.label)
