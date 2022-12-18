local colors = {
-- content here will not be touched
-- PATCH_OPEN
Normal = {fg = "#E4E0D8", bg = "#1F1F1F"},
Boolean = {fg = "#FF776B"},
CmpItemAbbrDeprecated = {fg = "#564A48", strikethrough = true},
CmpItemAbbrMatch = {fg = "#BDE97C"},
CmpItemAbbrMatchFuzzy = {link = "CmpItemAbbrMatch"},
Comment = {fg = "#9B988C", italic = true},
Constant = {fg = "#E5786C"},
Cursor = {bg = "#EFDDA9"},
CursorColumn = {link = "Cursor"},
CursorLine = {bg = "#32322F"},
Delimiter = {fg = "#D685FF"},
DiffAdd = {fg = "#000000", bg = "#9FDE3F"},
DiffChange = {bg = "#B295BB"},
DiffDelete = {fg = "#000000", bg = "#FF3624"},
DiffText = {fg = "#000000", bg = "#EF85FF"},
Directory = {fg = "#91FDF7"},
ErrorMsg = {fg = "#FF1F26", bg = "#454545", bold = true},
Exception = {fg = "#E5786C"},
FloatBorder = {fg = "#FFFFD6", bg = "#363636"},
Folded = {fg = "#9B988C", bg = "#564A48"},
FoldColumn = {link = "Folded"},
Function = {fg = "#BDE97C"},
TSFunction = {link = "Function"},
TSMethod = {link = "Function"},
Identifier = {fg = "#BDE97C"},
TSProperty = {link = "Identifier"},
Keyword = {fg = "#6DB9F8"},
TSKeyword = {link = "Keyword"},
Label = {fg = "#EF85FF"},
LineNr = {fg = "#564A48", bg = "#000000"},
NonText = {link = "LineNr"},
MatchParen = {fg = "#EFDDA9", bg = "#9B988C", bold = true},
NormalFloat = {fg = "#EFDDA9", bg = "#363636"},
Number = {fg = "#E5786C"},
Float = {link = "Number"},
Operator = {fg = "#EF85FF"},
Pmenu = {fg = "#FFFFD6", bg = "#454545"},
PmenuSel = {fg = "#000000", bg = "#BDE97C"},
PreProc = {fg = "#E5786C"},
Search = {fg = "#D685FF", bg = "#636066"},
Special = {fg = "#EFDDA9"},
TSVariable = {link = "Special"},
SpecialKey = {fg = "#636066", bg = "#32322F"},
Statement = {fg = "#6DB9F8"},
Conditional = {link = "Statement"},
Repeat = {link = "Statement"},
StatusLine = {fg = "#FFFFD6", bg = "#454545", italic = true},
StatusLineNC = {fg = "#9B988C", bg = "#454545"},
String = {fg = "#94E453", italic = true},
CmpItemKindFunction = {link = "TSFunction"},
CmpItemKindKeyword = {link = "TSKeyword"},
CmpItemKindMethod = {link = "TSMethod"},
CmpItemKindProperty = {link = "TSProperty"},
TSText = {fg = "#E4E0D8"},
CmpItemKindText = {link = "TSText"},
CmpItemKindInterface = {link = "TSType"},
CmpItemKindVariable = {link = "TSVariable"},
Title = {fg = "#FFFFD6", bold = true},
Todo = {fg = "#636066", italic = true},
Type = {fg = "#EFDDA9"},
TSType = {link = "Type"},
VertSplit = {fg = "#454545", bg = "#454545"},
Visual = {fg = "#C4C6CA", bg = "#564A48"},
VisualNOS = {fg = "#C4C6CA", bg = "#454545"},
WarningMsg = {fg = "#FF776B"},
-- PATCH_CLOSE
-- content here will not be touched
}

-- colorschemes generally want to do this
vim.cmd("highlight clear")
vim.cmd("set t_Co=256")
vim.cmd("let g:colors_name='my_theme'")

-- apply highlight groups
for group, attrs in pairs(colors) do
  vim.api.nvim_set_hl(0, group, attrs)
end
