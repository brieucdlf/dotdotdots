-- Nurburgreen — Neovim colorscheme
-- Porsche 911 GT3 · British Racing Green · Cognac leather · Carbon fiber

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
vim.g.colors_name = "nurburgreen"
vim.o.termguicolors = true

local c = {
  -- backgrounds
  bg        = "#001a0f",
  bg_dark   = "#000f08",
  bg_darker = "#000a05",
  bg_light  = "#0d3326",

  -- carbon surfaces
  surface0  = "#0a0e0a",
  surface1  = "#0d110d",
  surface2  = "#141814",
  surface3  = "#1a1e1a",

  -- cognac foregrounds
  fg_dim    = "#8a6835",
  fg_muted  = "#b8a07a",
  fg        = "#d4b88a",
  fg_bright = "#e0cba0",

  -- overlays
  overlay0  = "#2a2010",
  overlay1  = "#5a3a1a",
  overlay2  = "#8a6835",

  -- BRG green family
  green_dim   = "#003820",
  green       = "#004225",
  green_mid   = "#0a6b38",
  green_light = "#2a5a3a",
  teal        = "#1d6648",
  teal_light  = "#2d8060",

  -- cognac family
  cognac_dark  = "#6b3a1f",
  carbon       = "#2a302a",
  cognac       = "#8a6835",
  cognac_mid   = "#a06030",
  cognac_light = "#b8a07a",

  -- accents
  yellow      = "#f0c000",
  yellow_dim  = "#c49800",

  -- states
  red         = "#6b3a1f",
  red_bright  = "#a06030",

  none = "NONE",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ── Editor ────────────────────────────────────────────────────────────────────
hi("Normal",          { fg = c.fg,        bg = c.bg })
hi("NormalFloat",     { fg = c.fg,        bg = c.bg_dark })
hi("NormalNC",        { fg = c.fg_muted,  bg = c.bg })
hi("EndOfBuffer",     { fg = c.surface3 })
hi("NonText",         { fg = c.surface3 })
hi("Whitespace",      { fg = c.surface2 })

-- cursor
hi("Cursor",          { fg = c.bg,        bg = c.fg })
hi("CursorIM",        { fg = c.bg,        bg = c.fg })
hi("CursorLine",      { bg = c.surface0 })
hi("CursorColumn",    { bg = c.surface0 })
hi("ColorColumn",     { bg = c.surface1 })

-- line numbers
hi("LineNr",          { fg = c.surface3 })
hi("CursorLineNr",    { fg = c.cognac,   bold = true })
hi("LineNrAbove",     { fg = c.surface2 })
hi("LineNrBelow",     { fg = c.surface2 })

-- folds
hi("Folded",          { fg = c.overlay1,  bg = c.surface1 })
hi("FoldColumn",      { fg = c.overlay1,  bg = c.bg })
hi("SignColumn",      { fg = c.fg,        bg = c.bg })

-- splits / borders
hi("VertSplit",       { fg = c.surface3 })
hi("WinSeparator",    { fg = c.surface3 })
hi("FloatBorder",     { fg = c.green_light, bg = c.bg_dark })
hi("FloatTitle",      { fg = c.cognac,    bg = c.bg_dark, bold = true })

-- status / tabline
hi("StatusLine",      { fg = c.fg_muted,  bg = c.surface0 })
hi("StatusLineNC",    { fg = c.overlay1,  bg = c.surface0 })
hi("TabLine",         { fg = c.overlay1,  bg = c.surface0 })
hi("TabLineFill",     { bg = c.surface0 })
hi("TabLineSel",      { fg = c.fg,        bg = c.bg,       bold = true })
hi("WinBar",          { fg = c.fg_dim,    bg = c.bg })
hi("WinBarNC",        { fg = c.overlay1,  bg = c.bg })

-- selection
hi("Visual",          { bg = c.green_dim })
hi("VisualNOS",       { bg = c.green_dim })
hi("SelectionHL",     { bg = c.green_dim })

-- search
hi("Search",          { fg = c.bg,        bg = c.cognac })
hi("IncSearch",       { fg = c.bg,        bg = c.yellow })
hi("CurSearch",       { fg = c.bg,        bg = c.yellow, bold = true })
hi("Substitute",      { fg = c.bg,        bg = c.cognac_mid })

-- popup menu
hi("Pmenu",           { fg = c.fg_muted,  bg = c.surface1 })
hi("PmenuSel",        { fg = c.fg,        bg = c.green_light, bold = true })
hi("PmenuSbar",       { bg = c.surface2 })
hi("PmenuThumb",      { bg = c.green_light })
hi("PmenuExtra",      { fg = c.overlay2,  bg = c.surface1 })
hi("PmenuMatch",      { fg = c.yellow,    bg = c.surface1, bold = true })
hi("PmenuMatchSel",   { fg = c.yellow,    bg = c.green_light, bold = true })

-- match paren
hi("MatchParen",      { fg = c.yellow,    bold = true,     underline = true })

-- messages
hi("ModeMsg",         { fg = c.green_mid, bold = true })
hi("MoreMsg",         { fg = c.green_mid })
hi("WarningMsg",      { fg = c.cognac_mid })
hi("ErrorMsg",        { fg = c.red_bright })
hi("Question",        { fg = c.green_mid })
hi("Title",           { fg = c.fg_bright, bold = true })

-- special
hi("SpecialKey",      { fg = c.overlay2 })
hi("Conceal",         { fg = c.overlay1 })
hi("Directory",       { fg = c.green_mid, bold = true })
hi("QuickFixLine",    { bg = c.surface1 })

-- ── Syntax ────────────────────────────────────────────────────────────────────
hi("Comment",         { fg = c.carbon, italic = true })
hi("SpecialComment",  { fg = c.carbon, italic = true })
hi("Todo",            { fg = c.yellow,      bg = c.surface1, bold = true })

-- keywords
hi("Keyword",         { fg = c.green_mid,  bold = true })
hi("Statement",       { fg = c.green_mid,  bold = true })
hi("Conditional",     { fg = c.green_mid,  bold = true })
hi("Repeat",          { fg = c.green_mid,  bold = true })
hi("Label",           { fg = c.green_mid })
hi("Exception",       { fg = c.cognac_mid, bold = true })
hi("Operator",        { fg = c.cognac })

-- identifiers
hi("Identifier",      { fg = c.fg })
hi("Function",        { fg = c.fg_bright,  bold = true })

-- strings & constants
hi("String",          { fg = c.teal })
hi("Character",       { fg = c.teal })
hi("Number",          { fg = c.cognac_dark })
hi("Float",           { fg = c.cognac_dark })
hi("Boolean",         { fg = c.yellow,     bold = true })
hi("Constant",        { fg = c.cognac_dark })

-- types
hi("Type",            { fg = c.teal_light })
hi("StorageClass",    { fg = c.green_mid,  bold = true })
hi("Structure",       { fg = c.teal_light, bold = true })
hi("Typedef",         { fg = c.teal_light })

-- preprocessor
hi("PreProc",         { fg = c.cognac_mid })
hi("Include",         { fg = c.cognac_mid })
hi("Define",          { fg = c.cognac_mid })
hi("Macro",           { fg = c.cognac_mid })
hi("PreCondit",       { fg = c.cognac_mid })

-- special chars / tags
hi("Special",         { fg = c.cognac_light })
hi("SpecialChar",     { fg = c.cognac_light })
hi("Tag",             { fg = c.cognac })
hi("Delimiter",       { fg = c.overlay2 })

-- misc
hi("Underlined",      { underline = true })
hi("Ignore",          { fg = c.overlay1 })
hi("Error",           { fg = c.red_bright, bold = true })

-- ── Diagnostics ───────────────────────────────────────────────────────────────
hi("DiagnosticError",          { fg = c.cognac_mid })
hi("DiagnosticWarn",           { fg = c.cognac })
hi("DiagnosticInfo",           { fg = c.green_light })
hi("DiagnosticHint",           { fg = c.teal })
hi("DiagnosticOk",             { fg = c.green_mid })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.cognac_mid })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.cognac })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.green_light })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.teal })
hi("DiagnosticVirtualTextError", { fg = c.cognac_mid, bg = c.surface0, italic = true })
hi("DiagnosticVirtualTextWarn",  { fg = c.cognac,     bg = c.surface0, italic = true })
hi("DiagnosticVirtualTextInfo",  { fg = c.green_light, bg = c.surface0, italic = true })
hi("DiagnosticVirtualTextHint",  { fg = c.teal,        bg = c.surface0, italic = true })

-- ── Diff ──────────────────────────────────────────────────────────────────────
hi("DiffAdd",    { fg = c.green_mid,  bg = c.green_dim })
hi("DiffChange", { fg = c.cognac,     bg = c.overlay0 })
hi("DiffDelete", { fg = c.cognac_mid, bg = c.surface0 })
hi("DiffText",   { fg = c.fg,         bg = c.overlay0, bold = true })
hi("Added",      { fg = c.green_mid })
hi("Changed",    { fg = c.cognac })
hi("Removed",    { fg = c.cognac_mid })

-- ── Spell ─────────────────────────────────────────────────────────────────────
hi("SpellBad",   { undercurl = true, sp = c.cognac_mid })
hi("SpellCap",   { undercurl = true, sp = c.cognac })
hi("SpellRare",  { undercurl = true, sp = c.teal })
hi("SpellLocal", { undercurl = true, sp = c.green_light })

-- ── TreeSitter ────────────────────────────────────────────────────────────────
hi("@variable",                { fg = c.fg })
hi("@variable.builtin",        { fg = c.cognac_light, italic = true })
hi("@variable.parameter",      { fg = c.fg_muted })
hi("@variable.member",         { fg = c.fg })

hi("@constant",                { fg = c.cognac_dark })
hi("@constant.builtin",        { fg = c.yellow, bold = true })
hi("@constant.macro",          { fg = c.cognac_mid })

hi("@string",                  { fg = c.teal })
hi("@string.escape",           { fg = c.teal_light })
hi("@string.special",          { fg = c.cognac_light })
hi("@string.regexp",           { fg = c.teal_light })

hi("@number",                  { fg = c.cognac_dark })
hi("@number.float",            { fg = c.cognac_dark })
hi("@boolean",                 { fg = c.yellow, bold = true })

hi("@function",                { fg = c.fg_bright, bold = true })
hi("@function.builtin",        { fg = c.fg_bright })
hi("@function.call",           { fg = c.fg_bright })
hi("@function.macro",          { fg = c.cognac_mid })
hi("@function.method",         { fg = c.fg_bright, bold = true })
hi("@function.method.call",    { fg = c.fg_bright })

hi("@constructor",             { fg = c.teal_light, bold = true })
hi("@operator",                { fg = c.cognac })
hi("@keyword",                 { fg = c.green_mid, bold = true })
hi("@keyword.import",          { fg = c.cognac_mid })
hi("@keyword.return",          { fg = c.green_mid, bold = true })
hi("@keyword.operator",        { fg = c.cognac })
hi("@keyword.exception",       { fg = c.cognac_mid, bold = true })
hi("@keyword.conditional",     { fg = c.green_mid, bold = true })
hi("@keyword.repeat",          { fg = c.green_mid, bold = true })

hi("@type",                    { fg = c.teal_light })
hi("@type.builtin",            { fg = c.teal_light, italic = true })
hi("@type.definition",         { fg = c.teal_light, bold = true })

hi("@module",                  { fg = c.cognac_light })
hi("@label",                   { fg = c.green_mid })
hi("@comment",                 { fg = c.carbon, italic = true })
hi("@comment.todo",            { fg = c.yellow, bg = c.surface1, bold = true })
hi("@comment.warning",         { fg = c.cognac_mid, bg = c.surface1, bold = true })
hi("@punctuation.delimiter",   { fg = c.overlay2 })
hi("@punctuation.bracket",     { fg = c.fg_dim })
hi("@punctuation.special",     { fg = c.cognac })
hi("@tag",                     { fg = c.green_mid })
hi("@tag.attribute",           { fg = c.cognac_light, italic = true })
hi("@tag.delimiter",           { fg = c.overlay2 })

hi("@markup.heading",          { fg = c.fg_bright, bold = true })
hi("@markup.heading.1",        { fg = c.fg_bright, bold = true })
hi("@markup.heading.2",        { fg = c.cognac_light, bold = true })
hi("@markup.heading.3",        { fg = c.teal_light, bold = true })
hi("@markup.link",             { fg = c.teal, underline = true })
hi("@markup.link.url",         { fg = c.teal, underline = true })
hi("@markup.raw",              { fg = c.cognac_light, bg = c.surface1 })
hi("@markup.italic",           { italic = true })
hi("@markup.strong",           { bold = true })
hi("@markup.strikethrough",    { strikethrough = true })
hi("@markup.list",             { fg = c.green_mid })
hi("@markup.list.checked",     { fg = c.teal })
hi("@markup.list.unchecked",   { fg = c.overlay2 })

-- ── LSP ───────────────────────────────────────────────────────────────────────
hi("@lsp.type.class",          { fg = c.teal_light, bold = true })
hi("@lsp.type.enum",           { fg = c.teal_light })
hi("@lsp.type.enumMember",     { fg = c.cognac_dark })
hi("@lsp.type.function",       { fg = c.fg_bright, bold = true })
hi("@lsp.type.interface",      { fg = c.teal_light, italic = true })
hi("@lsp.type.keyword",        { fg = c.green_mid, bold = true })
hi("@lsp.type.method",         { fg = c.fg_bright })
hi("@lsp.type.namespace",      { fg = c.cognac_light })
hi("@lsp.type.parameter",      { fg = c.fg_muted })
hi("@lsp.type.property",       { fg = c.fg })
hi("@lsp.type.struct",         { fg = c.teal_light, bold = true })
hi("@lsp.type.type",           { fg = c.teal_light })
hi("@lsp.type.typeParameter",  { fg = c.teal, italic = true })
hi("@lsp.type.variable",       { fg = c.fg })
hi("LspReferenceText",         { bg = c.surface2 })
hi("LspReferenceRead",         { bg = c.surface2 })
hi("LspReferenceWrite",        { bg = c.surface2, bold = true })
hi("LspInlayHint",             { fg = c.overlay1, bg = c.surface0, italic = true })
hi("LspCodeLens",              { fg = c.overlay1, italic = true })

-- ── Telescope ─────────────────────────────────────────────────────────────────
hi("TelescopeBorder",         { fg = c.green_light,  bg = c.bg_dark })
hi("TelescopeNormal",         { fg = c.fg,           bg = c.bg_dark })
hi("TelescopeTitle",          { fg = c.cognac,       bg = c.bg_dark, bold = true })
hi("TelescopePromptBorder",   { fg = c.green_mid,    bg = c.surface0 })
hi("TelescopePromptNormal",   { fg = c.fg,           bg = c.surface0 })
hi("TelescopePromptTitle",    { fg = c.fg_bright,    bg = c.surface0, bold = true })
hi("TelescopePromptPrefix",   { fg = c.green_mid })
hi("TelescopePromptCounter",  { fg = c.overlay2 })
hi("TelescopeSelection",      { fg = c.fg,           bg = c.green_dim })
hi("TelescopeSelectionCaret", { fg = c.green_mid,    bg = c.green_dim })
hi("TelescopeMatching",       { fg = c.yellow,       bold = true })
hi("TelescopePreviewBorder",  { fg = c.surface3,     bg = c.bg_dark })
hi("TelescopePreviewTitle",   { fg = c.overlay2,     bg = c.bg_dark })

-- ── nvim-cmp ──────────────────────────────────────────────────────────────────
hi("CmpItemAbbr",           { fg = c.fg_muted })
hi("CmpItemAbbrMatch",      { fg = c.yellow,      bold = true })
hi("CmpItemAbbrMatchFuzzy", { fg = c.yellow_dim,  bold = true })
hi("CmpItemAbbrDeprecated", { fg = c.overlay1,    strikethrough = true })
hi("CmpItemMenu",           { fg = c.overlay2,    italic = true })
hi("CmpItemKindText",       { fg = c.fg })
hi("CmpItemKindFunction",   { fg = c.fg_bright })
hi("CmpItemKindMethod",     { fg = c.fg_bright })
hi("CmpItemKindConstructor",{ fg = c.teal_light })
hi("CmpItemKindField",      { fg = c.fg })
hi("CmpItemKindVariable",   { fg = c.fg })
hi("CmpItemKindClass",      { fg = c.teal_light })
hi("CmpItemKindInterface",  { fg = c.teal_light })
hi("CmpItemKindModule",     { fg = c.cognac_light })
hi("CmpItemKindProperty",   { fg = c.fg })
hi("CmpItemKindKeyword",    { fg = c.green_mid })
hi("CmpItemKindSnippet",    { fg = c.cognac })
hi("CmpItemKindEnum",       { fg = c.teal_light })
hi("CmpItemKindEnumMember", { fg = c.cognac_dark })
hi("CmpItemKindConstant",   { fg = c.cognac_dark })
hi("CmpItemKindStruct",     { fg = c.teal_light })
hi("CmpItemKindTypeParameter", { fg = c.teal })

-- ── Gitsigns ──────────────────────────────────────────────────────────────────
hi("GitSignsAdd",          { fg = c.green_mid })
hi("GitSignsChange",       { fg = c.cognac })
hi("GitSignsDelete",       { fg = c.cognac_mid })
hi("GitSignsAddNr",        { fg = c.green_mid })
hi("GitSignsChangeNr",     { fg = c.cognac })
hi("GitSignsDeleteNr",     { fg = c.cognac_mid })
hi("GitSignsAddLn",        { bg = c.green_dim })
hi("GitSignsChangeLn",     { bg = c.overlay0 })
hi("GitSignsCurrentLineBlame", { fg = c.overlay1, italic = true })

-- ── Snacks / notifications ────────────────────────────────────────────────────
hi("SnacksNotifierBorderError", { fg = c.cognac_mid })
hi("SnacksNotifierBorderWarn",  { fg = c.cognac })
hi("SnacksNotifierBorderInfo",  { fg = c.green_light })
hi("SnacksNotifierBorderDebug", { fg = c.overlay2 })
hi("SnacksNotifierBorderTrace", { fg = c.overlay1 })

-- ── indent-blankline ──────────────────────────────────────────────────────────
hi("IblIndent",     { fg = c.surface2 })
hi("IblScope",      { fg = c.green_dim })

-- ── nvim-tree / neo-tree ──────────────────────────────────────────────────────
hi("NvimTreeNormal",         { fg = c.fg_muted,  bg = c.bg_dark })
hi("NvimTreeFolderName",     { fg = c.fg,        bold = true })
hi("NvimTreeOpenedFolderName",{ fg = c.fg_bright, bold = true })
hi("NvimTreeRootFolder",     { fg = c.green_mid, bold = true })
hi("NvimTreeGitDirty",       { fg = c.cognac })
hi("NvimTreeGitNew",         { fg = c.green_mid })
hi("NvimTreeGitDeleted",     { fg = c.cognac_mid })
hi("NeoTreeNormal",          { fg = c.fg_muted,  bg = c.bg_dark })
hi("NeoTreeNormalNC",        { fg = c.fg_muted,  bg = c.bg_dark })
hi("NeoTreeRootName",        { fg = c.green_mid, bold = true })
hi("NeoTreeDirectoryName",   { fg = c.fg })
hi("NeoTreeGitModified",     { fg = c.cognac })
hi("NeoTreeGitAdded",        { fg = c.green_mid })
hi("NeoTreeGitDeleted",      { fg = c.cognac_mid })

-- ── which-key ────────────────────────────────────────────────────────────────
hi("WhichKey",          { fg = c.green_mid })
hi("WhichKeyDesc",      { fg = c.fg_muted })
hi("WhichKeyGroup",     { fg = c.cognac,   bold = true })
hi("WhichKeyBorder",    { fg = c.green_light })
hi("WhichKeyNormal",    { bg = c.bg_dark })
hi("WhichKeySeparator", { fg = c.overlay1 })
hi("WhichKeyValue",     { fg = c.overlay2 })

-- ── mini.nvim ─────────────────────────────────────────────────────────────────
hi("MiniStatuslineModeNormal",  { fg = c.bg,  bg = c.cognac,     bold = true })
hi("MiniStatuslineModeInsert",  { fg = c.bg,  bg = c.green_mid,  bold = true })
hi("MiniStatuslineModeVisual",  { fg = c.bg,  bg = c.yellow,     bold = true })
hi("MiniStatuslineModeReplace", { fg = c.bg,  bg = c.cognac_mid, bold = true })
hi("MiniStatuslineModeCommand", { fg = c.bg,  bg = c.teal,       bold = true })
hi("MiniStatuslineFilename",    { fg = c.fg_muted, bg = c.surface1 })
hi("MiniStatuslineFileinfo",    { fg = c.overlay2, bg = c.surface0 })
hi("MiniStatuslineInactive",    { fg = c.overlay1, bg = c.surface0 })
hi("MiniPickBorder",            { fg = c.green_light })
hi("MiniPickBorderFocus",       { fg = c.green_mid })
hi("MiniPickMatchCurrent",      { bg = c.green_dim })
hi("MiniPickMatchMarked",       { bg = c.overlay0 })
hi("MiniPickMatchRanges",       { fg = c.yellow, bold = true })
hi("MiniClueBorder",            { fg = c.green_light })
hi("MiniClueDescGroup",         { fg = c.cognac, bold = true })
hi("MiniClueDescSingle",        { fg = c.fg_muted })
hi("MiniClueNextKey",           { fg = c.green_mid })
hi("MiniClueNextKeyWithPostkeys",{ fg = c.yellow })

-- ── Noice ────────────────────────────────────────────────────────────────────
hi("NoiceCmdlinePopupBorder", { fg = c.green_light })
hi("NoiceCmdlineIcon",        { fg = c.green_mid })
hi("NoiceConfirmBorder",      { fg = c.green_light })
