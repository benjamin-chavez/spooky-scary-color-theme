local scriptPath = debug.getinfo(1, "S").source:sub(2)
local scriptDirectory = vim.fs.dirname(vim.fn.fnamemodify(scriptPath, ":p"))
local portDirectory = vim.env.SPOOKY_PORT_DIR or vim.fs.normalize(scriptDirectory .. "/../..")
local samplesDirectory = assert(vim.env.SPOOKY_SAMPLE_DIR, "SPOOKY_SAMPLE_DIR is required")
local outputDirectory = assert(vim.env.SPOOKY_OUT_DIR, "SPOOKY_OUT_DIR is required")
local treesitterDirectory = vim.env.NVIM_TREESITTER_DIR
  or vim.fn.expand("~/.local/share/nvim/lazy/nvim-treesitter")

assert(#vim.api.nvim_list_uis() > 0, "Run this inspector in a terminal without --headless")
vim.opt.runtimepath:prepend(treesitterDirectory)
vim.opt.runtimepath:prepend(portDirectory)
require("nvim-treesitter.query_predicates")
-- plugin/ files are only sourced at startup, so load the port's predicate explicitly.
vim.cmd("runtime! plugin/spooky-scary.lua")
vim.cmd.colorscheme(vim.env.SPOOKY_COLORSCHEME or "spooky-scary")
vim.o.lines = 80
vim.o.columns = 160
vim.o.laststatus = 0
vim.o.ruler = false
vim.o.showmode = false
vim.o.showcmd = false
vim.o.conceallevel = 0
vim.o.wrap = false
vim.o.number = false
vim.o.relativenumber = false
vim.o.signcolumn = "no"
vim.o.foldcolumn = "0"
vim.o.foldenable = false

local sampleLanguages = {
  js = "javascript", ts = "typescript", tsx = "tsx", html = "html", css = "css",
  json = "json", md = "markdown", py = "python", lua = "lua",
}
local normalHighlight = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
vim.fn.mkdir(outputDirectory, "p")

for _, sampleName in ipairs(vim.fn.readdir(samplesDirectory)) do
  local languageName = sampleLanguages[sampleName:match("%.(%w+)$")]
  if languageName then
    local sampleLines = vim.fn.readfile(samplesDirectory .. "/" .. sampleName)
    local sampleBuffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(sampleBuffer)
    vim.api.nvim_buf_set_lines(sampleBuffer, 0, -1, false, sampleLines)
    vim.bo[sampleBuffer].filetype = vim.filetype.match({ filename = sampleName }) or languageName
    vim.treesitter.start(sampleBuffer, languageName)
    vim.treesitter.get_parser(sampleBuffer, languageName):parse(true)
    vim.cmd("normal! gg0")
    vim.cmd("redraw!")
    -- The first inspection enables highlight metadata and invalidates cached screen attributes.
    vim.api.nvim__inspect_cell(1, 0, 0)
    vim.cmd("redraw!")

    local outputLines = {}
    for rowNumber, lineText in ipairs(sampleLines) do
      local lineRuns = {}
      local currentRun
      for columnNumber = 1, #lineText do
        local screenPosition = vim.fn.screenpos(0, rowNumber, columnNumber)
        assert(screenPosition.row > 0, "Sample exceeds the visible screen: " .. sampleName)
        local screenCell = vim.api.nvim__inspect_cell(1, screenPosition.row - 1, screenPosition.col - 1)
        assert(screenCell[1] == lineText:sub(columnNumber, columnNumber), "Screen text differs from sample")
        local highlightAttributes = screenCell[2]
        local cellStyle = {
          fg = string.format("#%06x", highlightAttributes.foreground or normalHighlight.fg),
          b = highlightAttributes.bold or false,
          i = highlightAttributes.italic or false,
          u = highlightAttributes.underline or false,
          strike = highlightAttributes.strikethrough or false,
        }
        if currentRun and currentRun.fg == cellStyle.fg and currentRun.b == cellStyle.b
          and currentRun.i == cellStyle.i and currentRun.u == cellStyle.u
          and currentRun.strike == cellStyle.strike then
          currentRun.e = columnNumber
        else
          currentRun = cellStyle
          currentRun.s = columnNumber - 1
          currentRun.e = columnNumber
          lineRuns[#lineRuns + 1] = currentRun
        end
      end
      outputLines[#outputLines + 1] = { text = lineText, runs = lineRuns }
    end
    vim.fn.writefile({ vim.json.encode({ sample = sampleName, lines = outputLines }) },
      outputDirectory .. "/" .. sampleName .. ".json")
    vim.api.nvim_buf_delete(sampleBuffer, { force = true })
  end
end

vim.cmd("qa!")
