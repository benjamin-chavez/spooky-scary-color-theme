;; extends

(quoted_attribute_value ["\"" "'"] @spooky.punctuation)
(doctype "doctype" @spooky.tag)

((doctype) @spooky.attribute.html
  (#lua-match? @spooky.attribute.html "^<![dD][oO][cC][tT][yY][pP][eE]%s+[hH][tT][mM][lL]%s*>$")
  (#offset! @spooky.attribute.html 0 9 0 -1))

(entity) @spooky.punctuation
((entity) @spooky.string
  (#offset! @spooky.string 0 1 0 -1))
