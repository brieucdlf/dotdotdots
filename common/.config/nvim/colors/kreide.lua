-- Kreide — Neovim colorscheme
-- Porsche 911 GT3 RS craie · bitume mouillé · étrier jaune
--
-- Les groupes de surbrillance sont ceux de nurburgreen.lua, aux mêmes rôles :
-- seule la table `c` change. Les noms sont neutres (mint/rust/slate) et non
-- ceux d'une palette précise, pour qu'un troisième thème puisse reprendre le
-- même fichier.
--
-- Les valeurs marquées d'une clé viennent de theme/kreide/colors.toml ; les
-- autres en sont des nuances (fonds, overlays), comme dans nurburgreen.lua.
-- Sortir tout ça de colors.toml reste le TODO « palette en dur ».

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
vim.g.colors_name = "kreide"
vim.o.termguicolors = true

local c = {
  -- fonds — bitume mouillé, tiré froid
  bg        = "#15181a",   -- background
  bg_dark   = "#101315",   -- ui.toml statusbar_bg
  bg_darker = "#0b0d0e",   -- color0, l'encre sous la voiture
  bg_light  = "#252b2f",

  -- surfaces — carrosserie dans l'ombre
  surface0  = "#101315",
  surface1  = "#161a1c",
  surface2  = "#1f2428",
  surface3  = "#2a2f33",   -- color8

  -- craie
  fg_dim    = "#6d7478",
  fg_muted  = "#9aa09f",   -- color7
  fg        = "#c9ccca",   -- foreground
  fg_bright = "#e6e9e7",   -- color15

  overlay0  = "#1c2023",
  overlay1  = "#3d4449",
  overlay2  = "#6d7478",

  -- la menthe de l'enseigne : la famille froide, là où nurburgreen a son vert
  sel_bg      = "#31373b",   -- selection_background, gris jante
  mint        = "#7c8983",   -- color2
  mint_bright = "#8fa7a2",   -- color14
  mint_dark   = "#6f8783",   -- color6
  mint_light  = "#94a29b",   -- color10
  slate       = "#4a5558",

  -- la seule chaude, et les neutres qui l'entourent
  steel        = "#7d8f9b",  -- color12, ciel gris — nombres et constantes
  carbon       = "#2a2f33",  -- color8
  comment      = "#5f6a6d",
  rust         = "#c0704a",  -- color9, rouille chaude
  rust_bright  = "#c0704a",  -- color9
  brique       = "#a4574a",  -- color1, brique froide
  mauve        = "#a99cb0",  -- color13

  yellow      = "#e8b33c",   -- accent, l'étrier de frein
  yellow_dim  = "#b8891f",

  red         = "#a4574a",   -- color1

  none = "NONE",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ── Editor ────────────────────────────────────────────────────────────────────
hi("Normal",          { fg = c.fg,        bg = c.none })
hi("NormalFloat",     { fg = c.fg,        bg = c.bg_dark })
hi("NormalNC",        { fg = c.fg_muted,  bg = c.none })
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
hi("LineNr",          { fg = c.slate })
hi("CursorLineNr",    { fg = c.rust,      bold = true })
hi("LineNrAbove",     { fg = c.sel_bg })
hi("LineNrBelow",     { fg = c.sel_bg })

-- folds
hi("Folded",          { fg = c.overlay1,  bg = c.surface1 })
hi("FoldColumn",      { fg = c.overlay1,  bg = c.bg })
hi("SignColumn",      { fg = c.fg,        bg = c.bg })

-- splits / borders
hi("VertSplit",       { fg = c.surface3 })
hi("WinSeparator",    { fg = c.surface3 })
hi("FloatBorder",     { fg = c.slate, bg = c.bg_dark })
hi("FloatTitle",      { fg = c.rust,    bg = c.bg_dark, bold = true })

-- status / tabline
hi("StatusLine",      { fg = c.fg_muted,  bg = c.surface0 })
hi("StatusLineNC",    { fg = c.overlay1,  bg = c.surface0 })
hi("TabLine",         { fg = c.overlay1,  bg = c.surface0 })
hi("TabLineFill",     { bg = c.surface0 })
hi("TabLineSel",      { fg = c.fg,        bg = c.bg,       bold = true })
hi("WinBar",          { fg = c.fg_dim,    bg = c.bg })
hi("WinBarNC",        { fg = c.overlay1,  bg = c.bg })

-- selection
hi("Visual",          { bg = c.sel_bg })
hi("VisualNOS",       { bg = c.sel_bg })
hi("SelectionHL",     { bg = c.sel_bg })

-- search
hi("Search",          { fg = c.bg,        bg = c.rust })
hi("IncSearch",       { fg = c.bg,        bg = c.yellow })
hi("CurSearch",       { fg = c.bg,        bg = c.yellow, bold = true })
hi("Substitute",      { fg = c.bg,        bg = c.brique })

-- popup menu
hi("Pmenu",           { fg = c.fg_muted,  bg = c.surface1 })
hi("PmenuSel",        { fg = c.fg,        bg = c.slate, bold = true })
hi("PmenuSbar",       { bg = c.surface2 })
hi("PmenuThumb",      { bg = c.slate })
hi("PmenuExtra",      { fg = c.overlay2,  bg = c.surface1 })
hi("PmenuMatch",      { fg = c.yellow,    bg = c.surface1, bold = true })
hi("PmenuMatchSel",   { fg = c.yellow,    bg = c.slate, bold = true })

-- match paren
hi("MatchParen",      { fg = c.yellow,    bold = true,     underline = true })

-- messages
hi("ModeMsg",         { fg = c.mint_bright, bold = true })
hi("MoreMsg",         { fg = c.mint_bright })
hi("WarningMsg",      { fg = c.brique })
hi("ErrorMsg",        { fg = c.rust_bright })
hi("Question",        { fg = c.mint_bright })
hi("Title",           { fg = c.fg_bright, bold = true })

-- special
hi("SpecialKey",      { fg = c.overlay2 })
hi("Conceal",         { fg = c.overlay1 })
hi("Directory",       { fg = c.mint_bright, bold = true })
hi("QuickFixLine",    { bg = c.surface1 })

-- ── Syntax ────────────────────────────────────────────────────────────────────
hi("Comment",         { fg = c.comment, italic = true })
hi("SpecialComment",  { fg = c.comment, italic = true })
hi("Todo",            { fg = c.yellow,      bg = c.surface1, bold = true })

-- keywords
hi("Keyword",         { fg = c.mint_bright,  bold = true })
hi("Statement",       { fg = c.mint_bright,  bold = true })
hi("Conditional",     { fg = c.mint_bright,  bold = true })
hi("Repeat",          { fg = c.mint_bright,  bold = true })
hi("Label",           { fg = c.mint_bright })
hi("Exception",       { fg = c.brique, bold = true })
hi("Operator",        { fg = c.rust })

-- identifiers
hi("Identifier",      { fg = c.fg })
hi("Function",        { fg = c.fg_bright,  bold = true })

-- strings & constants
hi("String",          { fg = c.mint_dark })
hi("Character",       { fg = c.mint_dark })
hi("Number",          { fg = c.steel })
hi("Float",           { fg = c.steel })
hi("Boolean",         { fg = c.yellow,     bold = true })
hi("Constant",        { fg = c.steel })

-- types
hi("Type",            { fg = c.mint_light })
hi("StorageClass",    { fg = c.mint_bright,  bold = true })
hi("Structure",       { fg = c.mint_light, bold = true })
hi("Typedef",         { fg = c.mint_light })

-- preprocessor
hi("PreProc",         { fg = c.brique })
hi("Include",         { fg = c.brique })
hi("Define",          { fg = c.brique })
hi("Macro",           { fg = c.brique })
hi("PreCondit",       { fg = c.brique })

-- special chars / tags
hi("Special",         { fg = c.mauve })
hi("SpecialChar",     { fg = c.mauve })
hi("Tag",             { fg = c.rust })
hi("Delimiter",       { fg = c.overlay2 })

-- misc
hi("Underlined",      { underline = true })
hi("Ignore",          { fg = c.overlay1 })
hi("Error",           { fg = c.rust_bright, bold = true })

-- ── Diagnostics ───────────────────────────────────────────────────────────────
hi("DiagnosticError",          { fg = c.brique })
hi("DiagnosticWarn",           { fg = c.rust })
hi("DiagnosticInfo",           { fg = c.slate })
hi("DiagnosticHint",           { fg = c.mint_dark })
hi("DiagnosticOk",             { fg = c.mint_bright })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.brique })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.rust })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.slate })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.mint_dark })
hi("DiagnosticVirtualTextError", { fg = c.brique, bg = c.surface0, italic = true })
hi("DiagnosticVirtualTextWarn",  { fg = c.rust,     bg = c.surface0, italic = true })
hi("DiagnosticVirtualTextInfo",  { fg = c.slate, bg = c.surface0, italic = true })
hi("DiagnosticVirtualTextHint",  { fg = c.mint_dark,        bg = c.surface0, italic = true })

-- ── Diff ──────────────────────────────────────────────────────────────────────
hi("DiffAdd",    { fg = c.mint_bright,  bg = c.sel_bg })
hi("DiffChange", { fg = c.rust,     bg = c.overlay0 })
hi("DiffDelete", { fg = c.brique, bg = c.surface0 })
hi("DiffText",   { fg = c.fg,         bg = c.overlay0, bold = true })
hi("Added",      { fg = c.mint_bright })
hi("Changed",    { fg = c.rust })
hi("Removed",    { fg = c.brique })

-- ── Spell ─────────────────────────────────────────────────────────────────────
hi("SpellBad",   { undercurl = true, sp = c.brique })
hi("SpellCap",   { undercurl = true, sp = c.rust })
hi("SpellRare",  { undercurl = true, sp = c.mint_dark })
hi("SpellLocal", { undercurl = true, sp = c.slate })

-- ── TreeSitter ────────────────────────────────────────────────────────────────
hi("@variable",                { fg = c.fg })
hi("@variable.builtin",        { fg = c.mauve, italic = true })
hi("@variable.parameter",      { fg = c.fg_muted })
hi("@variable.member",         { fg = c.fg })

hi("@constant",                { fg = c.steel })
hi("@constant.builtin",        { fg = c.yellow, bold = true })
hi("@constant.macro",          { fg = c.brique })

hi("@string",                  { fg = c.mint_dark })
hi("@string.escape",           { fg = c.mint_light })
hi("@string.special",          { fg = c.mauve })
hi("@string.regexp",           { fg = c.mint_light })

hi("@number",                  { fg = c.steel })
hi("@number.float",            { fg = c.steel })
hi("@boolean",                 { fg = c.yellow, bold = true })

hi("@function",                { fg = c.fg_bright, bold = true })
hi("@function.builtin",        { fg = c.fg_bright })
hi("@function.call",           { fg = c.fg_bright })
hi("@function.macro",          { fg = c.brique })
hi("@function.method",         { fg = c.fg_bright, bold = true })
hi("@function.method.call",    { fg = c.fg_bright })

hi("@constructor",             { fg = c.mint_light, bold = true })
hi("@operator",                { fg = c.rust })
hi("@keyword",                 { fg = c.mint_bright, bold = true })
hi("@keyword.import",          { fg = c.brique })
hi("@keyword.return",          { fg = c.mint_bright, bold = true })
hi("@keyword.operator",        { fg = c.rust })
hi("@keyword.exception",       { fg = c.brique, bold = true })
hi("@keyword.conditional",     { fg = c.mint_bright, bold = true })
hi("@keyword.repeat",          { fg = c.mint_bright, bold = true })

hi("@type",                    { fg = c.mint_light })
hi("@type.builtin",            { fg = c.mint_light, italic = true })
hi("@type.definition",         { fg = c.mint_light, bold = true })

hi("@module",                  { fg = c.mauve })
hi("@label",                   { fg = c.mint_bright })
hi("@comment",                 { fg = c.comment, italic = true })
hi("@comment.todo",            { fg = c.yellow, bg = c.surface1, bold = true })
hi("@comment.warning",         { fg = c.brique, bg = c.surface1, bold = true })
hi("@punctuation.delimiter",   { fg = c.overlay2 })
hi("@punctuation.bracket",     { fg = c.fg_dim })
hi("@punctuation.special",     { fg = c.rust })
hi("@tag",                     { fg = c.mint_bright })
hi("@tag.attribute",           { fg = c.mauve, italic = true })
hi("@tag.delimiter",           { fg = c.overlay2 })

hi("@markup.heading",          { fg = c.fg_bright, bold = true })
hi("@markup.heading.1",        { fg = c.fg_bright, bold = true })
hi("@markup.heading.2",        { fg = c.mauve, bold = true })
hi("@markup.heading.3",        { fg = c.mint_light, bold = true })
hi("@markup.link",             { fg = c.mint_dark, underline = true })
hi("@markup.link.url",         { fg = c.mint_dark, underline = true })
hi("@markup.raw",              { fg = c.mauve, bg = c.surface1 })
hi("@markup.italic",           { italic = true })
hi("@markup.strong",           { bold = true })
hi("@markup.strikethrough",    { strikethrough = true })
hi("@markup.list",             { fg = c.mint_bright })
hi("@markup.list.checked",     { fg = c.mint_dark })
hi("@markup.list.unchecked",   { fg = c.overlay2 })

-- ── LSP ───────────────────────────────────────────────────────────────────────
hi("@lsp.type.class",          { fg = c.mint_light, bold = true })
hi("@lsp.type.enum",           { fg = c.mint_light })
hi("@lsp.type.enumMember",     { fg = c.steel })
hi("@lsp.type.function",       { fg = c.fg_bright, bold = true })
hi("@lsp.type.interface",      { fg = c.mint_light, italic = true })
hi("@lsp.type.keyword",        { fg = c.mint_bright, bold = true })
hi("@lsp.type.method",         { fg = c.fg_bright })
hi("@lsp.type.namespace",      { fg = c.mauve })
hi("@lsp.type.parameter",      { fg = c.fg_muted })
hi("@lsp.type.property",       { fg = c.fg })
hi("@lsp.type.struct",         { fg = c.mint_light, bold = true })
hi("@lsp.type.type",           { fg = c.mint_light })
hi("@lsp.type.typeParameter",  { fg = c.mint_dark, italic = true })
hi("@lsp.type.variable",       { fg = c.fg })
hi("LspReferenceText",         { bg = c.surface2 })
hi("LspReferenceRead",         { bg = c.surface2 })
hi("LspReferenceWrite",        { bg = c.surface2, bold = true })
hi("LspInlayHint",             { fg = c.overlay1, bg = c.surface0, italic = true })
hi("LspCodeLens",              { fg = c.overlay1, italic = true })

-- ── Telescope ─────────────────────────────────────────────────────────────────
hi("TelescopeBorder",         { fg = c.slate,  bg = c.bg_dark })
hi("TelescopeNormal",         { fg = c.fg,           bg = c.bg_dark })
hi("TelescopeTitle",          { fg = c.rust,       bg = c.bg_dark, bold = true })
hi("TelescopePromptBorder",   { fg = c.mint_bright,    bg = c.surface0 })
hi("TelescopePromptNormal",   { fg = c.fg,           bg = c.surface0 })
hi("TelescopePromptTitle",    { fg = c.fg_bright,    bg = c.surface0, bold = true })
hi("TelescopePromptPrefix",   { fg = c.mint_bright })
hi("TelescopePromptCounter",  { fg = c.overlay2 })
hi("TelescopeSelection",      { fg = c.fg,           bg = c.sel_bg })
hi("TelescopeSelectionCaret", { fg = c.mint_bright,    bg = c.sel_bg })
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
hi("CmpItemKindConstructor",{ fg = c.mint_light })
hi("CmpItemKindField",      { fg = c.fg })
hi("CmpItemKindVariable",   { fg = c.fg })
hi("CmpItemKindClass",      { fg = c.mint_light })
hi("CmpItemKindInterface",  { fg = c.mint_light })
hi("CmpItemKindModule",     { fg = c.mauve })
hi("CmpItemKindProperty",   { fg = c.fg })
hi("CmpItemKindKeyword",    { fg = c.mint_bright })
hi("CmpItemKindSnippet",    { fg = c.rust })
hi("CmpItemKindEnum",       { fg = c.mint_light })
hi("CmpItemKindEnumMember", { fg = c.steel })
hi("CmpItemKindConstant",   { fg = c.steel })
hi("CmpItemKindStruct",     { fg = c.mint_light })
hi("CmpItemKindTypeParameter", { fg = c.mint_dark })

-- ── Gitsigns ──────────────────────────────────────────────────────────────────
hi("GitSignsAdd",          { fg = c.mint_bright })
hi("GitSignsChange",       { fg = c.rust })
hi("GitSignsDelete",       { fg = c.brique })
hi("GitSignsAddNr",        { fg = c.mint_bright })
hi("GitSignsChangeNr",     { fg = c.rust })
hi("GitSignsDeleteNr",     { fg = c.brique })
hi("GitSignsAddLn",        { bg = c.sel_bg })
hi("GitSignsChangeLn",     { bg = c.overlay0 })
hi("GitSignsCurrentLineBlame", { fg = c.overlay1, italic = true })

-- ── Snacks / notifications ────────────────────────────────────────────────────
hi("SnacksNotifierBorderError", { fg = c.brique })
hi("SnacksNotifierBorderWarn",  { fg = c.rust })
hi("SnacksNotifierBorderInfo",  { fg = c.slate })
hi("SnacksNotifierBorderDebug", { fg = c.overlay2 })
hi("SnacksNotifierBorderTrace", { fg = c.overlay1 })

-- ── Snacks Picker ─────────────────────────────────────────────────────────────
hi("SnacksPickerNormal",        { fg = c.fg,          bg = c.bg_dark })
hi("SnacksPickerBorder",        { fg = c.slate, bg = c.bg_dark })
hi("SnacksPickerTitle",         { fg = c.rust,      bg = c.bg_dark, bold = true })
hi("SnacksPickerFooter",        { fg = c.overlay2,    bg = c.bg_dark })
-- input
hi("SnacksPickerInputNormal",   { fg = c.fg,          bg = c.surface0 })
hi("SnacksPickerInputBorder",   { fg = c.mint_bright,   bg = c.surface0 })
hi("SnacksPickerPrompt",        { fg = c.mint_bright,   bg = c.surface0 })
-- list items
hi("SnacksPickerMatch",         { fg = c.yellow,      bold = true })
hi("SnacksPickerCursor",        { bg = c.sel_bg })
hi("SnacksPickerDir",           { fg = c.comment })
hi("SnacksPickerFile",          { fg = c.fg })
hi("SnacksPickerPathHidden",    { fg = c.comment })
hi("SnacksPickerGitFile",       { fg = c.fg })
hi("SnacksPickerGitStatus",     { fg = c.rust })
-- preview
hi("SnacksPickerPreviewNormal", { fg = c.fg,          bg = c.bg_dark })
hi("SnacksPickerPreviewBorder", { fg = c.surface3,    bg = c.bg_dark })
hi("SnacksPickerPreviewTitle",  { fg = c.overlay2,    bg = c.bg_dark })

-- ── indent-blankline ──────────────────────────────────────────────────────────
hi("IblIndent",     { fg = c.surface2 })
hi("IblScope",      { fg = c.sel_bg })

-- ── nvim-tree / neo-tree ──────────────────────────────────────────────────────
hi("NvimTreeNormal",         { fg = c.fg_muted,  bg = c.bg_dark })
hi("NvimTreeFolderName",     { fg = c.fg,        bold = true })
hi("NvimTreeOpenedFolderName",{ fg = c.fg_bright, bold = true })
hi("NvimTreeRootFolder",     { fg = c.mint_bright, bold = true })
hi("NvimTreeGitDirty",       { fg = c.rust })
hi("NvimTreeGitNew",         { fg = c.mint_bright })
hi("NvimTreeGitDeleted",     { fg = c.brique })
hi("NeoTreeNormal",          { fg = c.fg_muted,  bg = c.bg_dark })
hi("NeoTreeNormalNC",        { fg = c.fg_muted,  bg = c.bg_dark })
hi("NeoTreeRootName",        { fg = c.mint_bright, bold = true })
hi("NeoTreeDirectoryName",   { fg = c.fg })
hi("NeoTreeGitModified",     { fg = c.rust })
hi("NeoTreeGitAdded",        { fg = c.mint_bright })
hi("NeoTreeGitDeleted",      { fg = c.brique })

-- ── which-key ────────────────────────────────────────────────────────────────
hi("WhichKey",          { fg = c.mint_bright })
hi("WhichKeyDesc",      { fg = c.fg_muted })
hi("WhichKeyGroup",     { fg = c.rust,   bold = true })
hi("WhichKeyBorder",    { fg = c.slate })
hi("WhichKeyNormal",    { bg = c.bg_dark })
hi("WhichKeySeparator", { fg = c.overlay1 })
hi("WhichKeyValue",     { fg = c.overlay2 })

-- ── mini.nvim ─────────────────────────────────────────────────────────────────
hi("MiniStatuslineModeNormal",  { fg = c.bg,  bg = c.rust,     bold = true })
hi("MiniStatuslineModeInsert",  { fg = c.bg,  bg = c.mint_bright,  bold = true })
hi("MiniStatuslineModeVisual",  { fg = c.bg,  bg = c.yellow,     bold = true })
hi("MiniStatuslineModeReplace", { fg = c.bg,  bg = c.brique, bold = true })
hi("MiniStatuslineModeCommand", { fg = c.bg,  bg = c.mint_dark,       bold = true })
hi("MiniStatuslineFilename",    { fg = c.fg_muted, bg = c.surface1 })
hi("MiniStatuslineFileinfo",    { fg = c.overlay2, bg = c.surface0 })
hi("MiniStatuslineInactive",    { fg = c.overlay1, bg = c.surface0 })
hi("MiniPickBorder",            { fg = c.slate })
hi("MiniPickBorderFocus",       { fg = c.mint_bright })
hi("MiniPickMatchCurrent",      { bg = c.sel_bg })
hi("MiniPickMatchMarked",       { bg = c.overlay0 })
hi("MiniPickMatchRanges",       { fg = c.yellow, bold = true })
hi("MiniClueBorder",            { fg = c.slate })
hi("MiniClueDescGroup",         { fg = c.rust, bold = true })
hi("MiniClueDescSingle",        { fg = c.fg_muted })
hi("MiniClueNextKey",           { fg = c.mint_bright })
hi("MiniClueNextKeyWithPostkeys",{ fg = c.yellow })

-- ── Diffview ─────────────────────────────────────────────────────────────────
hi("DiffviewNormal",              { fg = c.fg_muted,   bg = c.bg_dark })
hi("DiffviewFilePanelTitle",      { fg = c.fg_bright,  bold = true })
hi("DiffviewFilePanelCounter",    { fg = c.overlay2 })
hi("DiffviewFilePanelFileName",   { fg = c.fg })
hi("DiffviewFilePanelPath",       { fg = c.fg_dim })
hi("DiffviewFilePanelRootPath",   { fg = c.mint_bright,  bold = true })
hi("DiffviewFilePanelInsertions", { fg = c.mint_bright })
hi("DiffviewFilePanelDeletions",  { fg = c.brique })
hi("DiffviewStatusModified",      { fg = c.rust })
hi("DiffviewStatusAdded",         { fg = c.mint_bright })
hi("DiffviewStatusDeleted",       { fg = c.brique })
hi("DiffviewStatusRenamed",       { fg = c.mint_light })
hi("DiffviewStatusUnmerged",      { fg = c.yellow })

-- ── Noice ────────────────────────────────────────────────────────────────────
hi("NoiceCmdlinePopupBorder", { fg = c.slate })
hi("NoiceCmdlineIcon",        { fg = c.mint_bright })
hi("NoiceConfirmBorder",      { fg = c.slate })
