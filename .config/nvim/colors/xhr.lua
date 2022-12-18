local colors = {
-- content here will not be touched
-- PATCH_OPEN
Normal = {fg = "#E4E1D8", bg = "#242424"},
Comment = {fg = "#9B988C", italic = true},
Constant = {fg = "#E5786C"},
Cursor = {bg = "#EFDDA9"},
CursorColumn = {link = "Cursor"},
CursorLine = {bg = "#32322F"},
DiffAdd = {bg = "#2A0D68"},
DiffChange = {bg = "#372A36"},
DiffDelete = {fg = "#242424", bg = "#3E396A"},
DiffText = {bg = "#372A36"},
Directory = {fg = "#91FDF7"},
ErrorMsg = {fg = "#FF1F26", bg = "#454545", bold = true},
Folded = {fg = "#9B988C", bg = "#564A48"},
FoldColumn = {link = "Folded"},
Function = {fg = "#BDE97C"},
Identifier = {fg = "#BDE97C"},
Keyword = {fg = "#6DB9F8"},
LineNr = {fg = "#564A48", bg = "#000000"},
NonText = {link = "LineNr"},
MatchParen = {fg = "#EFDDA9", bg = "#9B988C", bold = true},
Number = {fg = "#E5786C"},
Pmenu = {fg = "#FFFFD6", bg = "#454545"},
PmenuSel = {fg = "#000000", bg = "#BDE97C"},
PreProc = {fg = "#E5786C"},
Search = {fg = "#D685FF", bg = "#636066"},
Special = {fg = "#EFDDA9"},
SpecialKey = {fg = "#636066", bg = "#32322F"},
Statement = {fg = "#6DB9F8"},
StatusLine = {fg = "#FFFFD6", bg = "#454545", italic = true},
StatusLineNC = {fg = "#9B988C", bg = "#454545"},
String = {fg = "#94E453", italic = true},
Title = {fg = "#FFFFD6", bold = true},
Todo = {fg = "#636066", italic = true},
Type = {fg = "#EFDDA9"},
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
