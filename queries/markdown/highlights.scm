;; extends

; text.html.markdown paints prose near-white. Priority 99 lets every real capture win.
((inline) @markup.plain
  (#set! priority 99))

((pipe_table_cell) @markup.plain
  (#set! priority 99))
