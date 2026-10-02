;; extends

([(inline) (pipe_table_cell)] @spooky.markup.plain
  (#set! priority 99))

[(atx_h1_marker) (atx_h2_marker) (atx_h3_marker)
 (atx_h4_marker) (atx_h5_marker) (atx_h6_marker)] @spooky.markup.heading.marker
(indented_code_block) @spooky.markup.raw.block
(fenced_code_block_delimiter) @spooky.punctuation
(thematic_break) @spooky.markup.separator
(link_label ["[" "]"] @spooky.punctuation)
(task_list_marker_unchecked) @spooky.markup.plain

((task_list_marker_checked) @spooky.markup.link.label
  (#offset! @spooky.markup.link.label 0 1 0 -1))
