# Spooky Scary Color Theme 

Hey you! Interested in a theme that'll send SHIVERS down your spine and give you an all around Halloween vibe?! Well you've come to the right theme! Inspired by  Halloween, spooky season, and Tim Burton films, this theme was born by a dev who absolutely adores all these things!

![Preview of Spooky Scary Color Theme: a black, green, orange and purple VS Code Theme](https://media.giphy.com/media/ZljsomV1FjhgkVIjYh/source.gif)
>Let's ignore the fact that my fingers type faster than my brain, I meant to write an h2 and not an h1, ty! :)

![Preview of Spooky Scary Color Theme: a black, green, orange and purple VS Code Theme](https://raw.githubusercontent.com/rojhanpaydar/spooky-scary-color-theme/main/previewImage.png?token=ANZ5BYHQ4U2PYB34ZHEM35LBLOTBA)

The best feature is all thanks to the folks who created the extension called "POWER MODE".

[link to Power Mode extension here](https://marketplace.visualstudio.com/items?itemName=hoovercj.vscode-power-mode&ssr=false#overview)

Using the genius behind Power Mode, I was able to include a little ghost friend to pop up and haunt your editor after a few key types!

![An animated looping image of a cartoon ghost flying upward and disappearing](https://media.giphy.com/media/8CZkmk6VsWmf5TfxNo/giphy.gif)
> Credits to the original author of this gif [Finkel Band](https://giphy.com/finkelband). I had to speed it up and [post my own faster version of this gif](https://media.giphy.com/media/WngnWxxekMn8DIqmwQ/giphy.gif) so it would render in a faster enough time on each click! Also, I will not be removing this gif so it can be used forever!

To add a GHOST to your editor, you'll need to install the [Power Mode Extention](https://marketplace.visualstudio.com/items?itemName=hoovercj.vscode-power-mode&ssr=false#overview), open up settings.json, and paste the following code inside your settings.json:

```
// added powermode ext
"powermode.enabled": true,

"powermode.explosions.customExplosions": [
  // direct path does not work, gif I uploaded to giphy
  "https://media.giphy.com/media/WngnWxxekMn8DIqmwQ/giphy.gif"
],

// this allows the little ghost friend to pop up above your line so you can see what you're typing!
"powermode.explosions.customCss": {
  "top": "-30px",
  "z-index": 1,
  "height": "70px",
  "width": "70px",
},

// stops the editor from shaking on each type
"powermode.shake.enabled": false,

// minimizes how often there is an appearance from our little ghost friend!
"powermode.explosions.maxExplosions": 1, 

// how many key hits until our ghost friend comes out to haunt us! :scream:
"powermode.explosions.frequency": 20,
```

Additionally, I'm using the font "Fira Code", plugged into my settings.json like so: 

```
"editor.fontFamily": "Fira Code",
    "editor.fontLigatures": true,
```

After you set that up, you should be good to GHOoOoOoST!

Happy Spooky Season y'all, I hope this theme brings you lots of good spooky vibes!!!

![An animated looping image of a cartoon pumpkin that reads 'happy halloween'](https://media.giphy.com/media/OoYrQPHwYpYnXhllfe/giphy.gif)

Resources and guides:
 
[Monica Powell's](https://twitter.com/indigitalcolor/) article to set up Power Mode extension: [How to Make Your VSCode Sparkle](https://aboutmonica.com/blog/how-to-make-your-vs-code-sparkle)

[Cody Hoover's](https://twitter.com/hoovercj) extension Power Mode: [Power Mode Extension](https://marketplace.visualstudio.com/items?itemName=hoovercj.vscode-power-mode&ssr=false#overview)

[Ivan Stevkovski's](https://www.linkedin.com/in/istevkovski/?originalSubdomain=mk) guide to make a VS Code theme: [Create Your Own Custom Theme Extension](https://medium.com/wearelaika/vscode-create-your-own-custom-theme-extension-96c67bd753f6)


## Neovim

The theme ships as a Neovim colorscheme on the `nvim-fork` branch. With lazy.nvim:

```lua
{
  "rojhanpaydar/spooky-scary-color-theme",
  branch = "nvim-fork",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("spooky-scary")
  end,
}
```

It requires `termguicolors` and uses treesitter captures. A lualine theme is included under the
same name, and highlight groups are defined for bufferline, nvim-tree, telescope, gitsigns,
nvim-cmp, indent-blankline, which-key, render-markdown and todo-comments.

The repo also ships small `queries/*/highlights.scm` extensions so Neovim can color string
quotes, brackets, block-scoped variables, JSON key depth and Markdown prose the way VS Code's
TextMate grammars do. They only add private `@spooky.*` captures, which no other colorscheme
defines, so switching themes renders exactly as before. `plugin/spooky-scary.lua` registers
the one query predicate they use.

### The ghost

The Power Mode ghost from above works in Neovim too, without Power Mode. Enable it after the
colorscheme loads:

```lua
require("spooky-scary.haunt").setup({
  frequency = 20, -- keystrokes between hauntings, like powermode.explosions.frequency
})
```

Every twenty characters typed in insert mode, a small purple ghost rises out of the cursor
line and vanishes, the way it does in the preview at the top of this README. In Ghostty, Kitty
or WezTerm it is the README's GIF drawn with the Kitty graphics protocol, cropped and tinted to
match Power Mode's rendering. In other terminals, or inside tmux, a ghost glyph rises and fades
instead. `:SpookyHaunt` summons it on demand, `graphics = "text"` forces the glyph version, and
`columns`, `rows` and `column_offset` move or resize it. `frames.lua` and the PNG frames under
`assets/ghost` come from `tools/ghost-frames.sh`.

The colors are verified against VS Code's own tokenizer by `tools/compare/run.sh`, which needs
Node, tmux and a local VS Code install for its grammars. It paints each sample in a real Neovim
and diffs every character. The few remaining differences are listed with reasons in
`tools/compare/known-differences.json`.
