;; extends

(link_title) @spooky.markup.link.title
(link_title ["\"" "'"] @spooky.punctuation)
(image_description) @spooky.markup.link.description
(link_label) @spooky.markup.link.reference
(link_label ["[" "]"] @spooky.punctuation)

[(uri_autolink) (email_autolink)] @spooky.markup.link.delimiter
([(uri_autolink) (email_autolink)] @spooky.markup.link.url
  (#offset! @spooky.markup.link.url 0 1 0 -1))

((emphasis (strong_emphasis)) @spooky.markup.strong
  (#set! priority 110))
((emphasis) @spooky.markup.strong
  (#has-ancestor? @spooky.markup.strong strong_emphasis)
  (#set! priority 110))

((emphasis_delimiter) @spooky.markup.delimiter.strong
  (#has-ancestor? @spooky.markup.delimiter.strong strong_emphasis)
  (#set! priority 120))
((emphasis (emphasis_delimiter) @spooky.markup.delimiter.strong (strong_emphasis))
  (#set! priority 120))
((emphasis (strong_emphasis) (emphasis_delimiter) @spooky.markup.delimiter.strong)
  (#set! priority 120))
