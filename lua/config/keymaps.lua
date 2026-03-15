-- Keymaps

-- Nvim Tree
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")

-- Trim whitespace on current line
vim.keymap.set("n", "<leader>tw", ":s/\\s\\+$//e<CR>")

-- Debugging
vim.keymap.set(
	"n",
	"<leader>en",
	":lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR, wrap = true})<CR>"
)
vim.keymap.set(
	"n",
	"<leader>ep",
	":lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR, wrap = true})<CR>"
)
vim.keymap.set("n", "<leader>eo", ":lua vim.diagnostic.open_float()<CR>")

-- Telescope
vim.keymap.set("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>fw", ":Telescope lsp_workspace_symbols<CR>")
vim.keymap.set(
	"n",
	"<leader>r",
	"<cmd>lua require('telescope.builtin').lsp_references()<CR>",
	{ noremap = true, silent = true }
)

-- Gen (Ollama)
vim.keymap.set("n", "<leader>-", ":Gen<CR>")

-- Move lines and indent
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Add lines without entering insert mode (safe on non-modifiable buffers)
local function ensure_modifiable()
	if not vim.bo.modifiable or vim.bo.readonly then
		vim.notify("Buffer is not modifiable", vim.log.levels.WARN)
		return false
	end
	return true
end

vim.keymap.set("n", "<leader>j", function()
	if not ensure_modifiable() then
		return
	end
	local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
	-- insert below current line: start=end=row (0-based)
	vim.api.nvim_buf_set_lines(0, row, row, true, { "" })
end, { desc = "Add blank line below without entering insert mode" })

vim.keymap.set("n", "<leader>k", function()
	if not ensure_modifiable() then
		return
	end
	local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
	local idx = math.max(row - 1, 0)           -- convert to 0-based, clamp at top
	-- insert above current line: start=end=idx (0-based)
	vim.api.nvim_buf_set_lines(0, idx, idx, true, { "" })
end, { desc = "Add blank line above without entering insert mode" })

-- Paste over selection
vim.keymap.set("x", "<leader>p", [["+dP]])
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- Import symbol under cursor
vim.keymap.set("n", "<leader>i", function()
	vim.lsp.buf.code_action({
		filter = function(action)
			return action.title:match("import") ~= nil
		end,
		apply = true,
	})
end, { desc = "Import symbol under cursor" })

-- Code actions
vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")

-- Cargo watch in a vertical split
vim.keymap.set("n", "<leader>cw", function()
	vim.cmd("vsplit")
	vim.cmd("terminal cargo watch -x run --poll -c")
end, { desc = "Cargo watch in split" })

-- Other keymapping
vim.keymap.set("n", "<leader>ll", "<cmd>Other<CR>")
vim.keymap.set("n", "<leader>ltn", "<cmd>OtherTabNew<CR>")
vim.keymap.set("n", "<leader>lp", "<cmd>OtherSplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lv", "<cmd>OtherVSplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lc", "<cmd>OtherClear<CR>", { noremap = true, silent = true })

-- Context specific bindings
vim.keymap.set("n", "<leader>lt", "<cmd>Other test<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ls", "<cmd>Other scss<CR>", { noremap = true, silent = true })

-- Insert mode navigation
vim.keymap.set("i", "<C-l>", "<C-o>l")
vim.keymap.set("i", "<C-h>", "<C-o>h")
vim.keymap.set("i", "<C-j>", "<C-o>j")
vim.keymap.set("i", "<C-k>", "<C-o>k")

-- Remapping notes
vim.keymap.set("n", "<leader>nl", "<cmd>NotesList<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ns", "<cmd>NotesSync<CR>", { desc = "Notes: manual sync" })

-- Adjusting vertical window size
vim.keymap.set("n", "<leader>.", ":vertical resize -5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>,", ":vertical resize +5<CR>", { noremap = true, silent = true })

-- Color picker
vim.keymap.set("n", "<leader>cp", "<cmd>CccPick<CR>")

-- Git add all, commit, push
function _G.gitAddCommitPush()
	local msg = vim.fn.input("Commit message: ")
	if msg == "" then
		print("No commit message provided. Aborting.")
		return
	end
	vim.schedule(function()
		vim.cmd("Git add -A")
		vim.cmd("Git commit -m " .. vim.fn.shellescape(msg))
		vim.cmd("Git push")
	end)
end

vim.keymap.set("n", "<leader>ac", ":lua gitAddCommitPush()<CR>", { noremap = true, silent = true })

-- Resource monitor
vim.keymap.set("n", "<leader>rm", ":ResMonToggle<CR>")

-- Code diff
vim.keymap.set("n", "<leader>cd", ":CodeDiff<CR>")

-- New LaTeX file
vim.keymap.set("n", "<leader>nt", function()
	vim.ui.input({ prompt = "LaTeX filename: " }, function(name)
		if not name or name == "" then
			return
		end
		if not name:match("%.tex$") then
			name = name .. ".tex"
		end
		local dir = vim.fn.expand("~/Projects/LaTeX")
		vim.fn.mkdir(dir, "p")
		local filepath = dir .. "/" .. name
		local expanded = vim.fn.expand(filepath)
		if vim.fn.filereadable(expanded) == 0 then
			vim.fn.writefile({
				"\\documentclass[a4paper,12pt]{article}",
				"\\usepackage[margin=2.5cm]{geometry}",
				"",
				"\\begin{document}",
				"",
				"\\end{document}",
			}, expanded)
		end
		vim.cmd("edit " .. vim.fn.fnameescape(filepath))
	end)
end, { desc = "New LaTeX file" })

-- LaTeX cheat sheet popup
local latex_cheatsheet_buf = nil
local latex_cheatsheet_win = nil

local function close_latex_cheatsheet()
	if latex_cheatsheet_win and vim.api.nvim_win_is_valid(latex_cheatsheet_win) then
		vim.api.nvim_win_close(latex_cheatsheet_win, true)
	end
	latex_cheatsheet_win = nil
	latex_cheatsheet_buf = nil
end

local function open_latex_cheatsheet()
	if latex_cheatsheet_win and vim.api.nvim_win_is_valid(latex_cheatsheet_win) then
		close_latex_cheatsheet()
		return
	end

	-- highlight groups
	vim.api.nvim_set_hl(0, "LtxHead", { bold = true, underline = true, fg = "#93c5fd" })
	vim.api.nvim_set_hl(0, "LtxColHead", { bold = true, fg = "#6b7280" })
	vim.api.nvim_set_hl(0, "LtxSep", { fg = "#374151" })
	vim.api.nvim_set_hl(0, "LtxBold", { bold = true })
	vim.api.nvim_set_hl(0, "LtxItalic", { italic = true })
	vim.api.nvim_set_hl(0, "LtxUnder", { underline = true })
	vim.api.nvim_set_hl(0, "LtxMono", { fg = "#a5f3fc", bg = "#1e293b" })
	vim.api.nvim_set_hl(0, "LtxSmallCap", { bold = true, fg = "#d1d5db" })
	vim.api.nvim_set_hl(0, "LtxRed", { fg = "#ef4444" })
	vim.api.nvim_set_hl(0, "LtxYellowBg", { bg = "#854d0e", fg = "#fef08a" })
	vim.api.nvim_set_hl(0, "LtxLink", { fg = "#60a5fa", underline = true })
	vim.api.nvim_set_hl(0, "LtxDim", { fg = "#6b7280" })
	vim.api.nvim_set_hl(0, "LtxBright", { bold = true, fg = "#f9fafb" })
	vim.api.nvim_set_hl(0, "LtxPkg", { fg = "#6ee7b7" })
	vim.api.nvim_set_hl(0, "LtxMath", { fg = "#fbbf24" })
	vim.api.nvim_set_hl(0, "LtxBullet", { fg = "#fb923c" })
	vim.api.nvim_set_hl(0, "LtxPartDemo", { bold = true, fg = "#c4b5fd", underline = true })
	vim.api.nvim_set_hl(0, "LtxChapDemo", { bold = true, fg = "#a5b4fc" })
	vim.api.nvim_set_hl(0, "LtxSecDemo", { bold = true })
	vim.api.nvim_set_hl(0, "LtxSubsecDemo", { bold = true, fg = "#d1d5db" })
	vim.api.nvim_set_hl(0, "LtxParDemo", { bold = true, italic = true, fg = "#9ca3af" })
	vim.api.nvim_set_hl(0, "LtxFootnote", { fg = "#9ca3af", underline = true })

	local CMD = 2
	local DEMO = 46
	local PKG = 72
	local WIDTH = 90

	local lines = {}
	local marks = {} -- {line_0idx, col_start_byte, col_end_byte, hl_group}

	local function pad(s, target_width)
		local w = vim.api.nvim_strwidth(s)
		if w >= target_width then
			return s .. " "
		end
		return s .. string.rep(" ", target_width - w)
	end

	local function add(text)
		table.insert(lines, text)
	end

	-- add a line and record highlights on the demo and pkg portions
	-- demo_hls: list of {text, hl_group} for the demo column
	-- pkg_text: string for the package column
	local function entry(cmd, demo_hls, pkg_text)
		local left = pad(string.rep(" ", CMD) .. cmd, DEMO)
		local demo_str = ""
		local demo_marks = {}
		for _, part in ipairs(demo_hls) do
			local start = #demo_str
			demo_str = demo_str .. part[1]
			if part[2] then
				table.insert(demo_marks, { start, #demo_str, part[2] })
			end
		end
		local mid = pad(left .. demo_str, PKG)
		local full = pad(mid .. pkg_text, WIDTH)
		add(full)
		local li = #lines - 1
		local base = #left -- byte offset where demo column starts
		for _, m in ipairs(demo_marks) do
			table.insert(marks, { li, base + m[1], base + m[2], m[3] })
		end
		if pkg_text ~= "" then
			local pkg_byte = #mid
			table.insert(marks, { li, pkg_byte, pkg_byte + #pkg_text, "LtxPkg" })
		end
	end

	local function header(num, title)
		local text = pad(string.format("  %d  %s", num, title), WIDTH)
		add(text)
		local li = #lines - 1
		table.insert(marks, { li, 2, #text, "LtxHead" })
	end

	local function sep()
		add("  " .. string.rep("─", WIDTH - 2))
		table.insert(marks, { #lines - 1, 0, #lines[#lines], "LtxSep" })
	end

	local function col_header()
		local text = pad(pad(pad(string.rep(" ", CMD) .. "COMMAND", DEMO) .. "OUTPUT", PKG) .. "PACKAGE", WIDTH)
		add(text)
		local li = #lines - 1
		table.insert(marks, { li, 0, #text, "LtxColHead" })
	end

	-- helpers for demo column fragments
	local function d(text, hl) return { text, hl } end
	local function plain(text) return { text, nil } end

	-- ── build content ──

	col_header()
	sep()
	add("")

	header(1, "Document Structure")
	sep()
	entry("\\documentclass[opts]{class}", {}, "")
	entry("\\usepackage[opts]{pkg}", {}, "")
	entry("\\begin{document} ... \\end{document}", {}, "")
	add("")

	header(2, "Sectioning")
	sep()
	entry("\\part{Title}", { d("Part I \u{2014} Title", "LtxPartDemo") }, "")
	entry("\\chapter{Title}", { d("Chapter 1. Title", "LtxChapDemo") }, "book/report")
	entry("\\section{Title}", { d("1  Title", "LtxSecDemo") }, "")
	entry("\\section*{Title}", { d("Title", "LtxSecDemo"), plain("  (unnumbered)") }, "")
	entry("\\subsection{Title}", { d("1.1  Title", "LtxSubsecDemo") }, "")
	entry("\\subsubsection{Title}", { d("1.1.1  Title", "LtxSubsecDemo") }, "")
	entry("\\paragraph{Title}", { d("Title", "LtxParDemo"), plain("  Lorem ipsum...") }, "")
	add("")

	header(3, "Text Formatting")
	sep()
	entry("\\textbf{text}", { d("Bold text", "LtxBold") }, "")
	entry("\\textit{text}", { d("Italic text", "LtxItalic") }, "")
	entry("\\underline{text}", { d("Underlined text", "LtxUnder") }, "")
	entry("\\emph{text}", { d("Emphasized", "LtxItalic") }, "")
	entry("\\texttt{text}", { d(" Monospaced ", "LtxMono") }, "")
	entry("\\textsc{Text}", { d("SMALL CAPS", "LtxSmallCap") }, "")
	entry("{\\bfseries scope}", { d("Bold scope", "LtxBold") }, "")
	entry("\\textcolor{red}{text}", { d("Colored text", "LtxRed") }, "xcolor")
	entry("\\colorbox{yellow}{text}", { d(" Highlighted ", "LtxYellowBg") }, "xcolor")
	entry("\\href{url}{text}", { d("Linked text", "LtxLink") }, "hyperref")
	entry("\\url{https://...}", { d("https://example.com", "LtxLink") }, "hyperref")
	add("")

	header(4, "Font Size")
	sep()
	entry("\\tiny  \\scriptsize", { d("tiny", "LtxDim"), plain("  "), d("scriptsize", "LtxDim") }, "")
	entry("\\footnotesize  \\small", { d("footnote", "LtxDim"), plain("  "), d("small", "LtxDim") }, "")
	entry("\\normalsize", { plain("normal size text") }, "")
	entry("\\large  \\Large  \\LARGE", { d("large", "LtxBold"), plain("  "), d("Large", "LtxBold"), plain("  "), d("LARGE", "LtxBright") }, "")
	entry("\\huge  \\Huge", { d("huge", "LtxBright"), plain("  "), d("HUGE", "LtxBright") }, "")
	add("")

	header(5, "Alignment")
	sep()
	entry("\\begin{center}  \\centering", { plain("    Centered text") }, "")
	entry("\\begin{flushleft}", { plain("Left-aligned") }, "")
	entry("\\begin{flushright}", { plain("        Right-aligned") }, "")
	add("")

	header(6, "Lists")
	sep()
	entry("\\begin{itemize}", { d("\u{2022}", "LtxBullet"), plain(" First  "), d("\u{2022}", "LtxBullet"), plain(" Second") }, "")
	entry("\\begin{enumerate}", { d("1.", "LtxBullet"), plain(" First  "), d("2.", "LtxBullet"), plain(" Second") }, "")
	entry("\\begin{description}", { d("Term", "LtxBold"), plain("  Definition") }, "")
	entry("[label=\\alph*)]", { d("a)", "LtxBullet"), plain(" First  "), d("b)", "LtxBullet"), plain(" Second") }, "enumitem")
	add("")

	header(7, "Figures & Images")
	sep()
	entry("\\begin{figure}[htbp]", {}, "")
	entry("\\includegraphics[w=..]{img}", { d("\u{1f5bc} ", "LtxDim"), plain("image.png") }, "graphicx")
	entry("\\caption{text}", { d("Figure 1:", "LtxItalic"), plain(" Caption text") }, "")
	entry("\\label{fig:x}  \\ref{fig:x}", { plain("see "), d("Figure 1", "LtxLink") }, "")
	add("")

	header(8, "Tables")
	sep()
	entry("\\begin{tabular}{l|c|r}", { d("\u{250c}\u{2500}\u{2500}\u{252c}\u{2500}\u{2500}\u{2510} \u{2502}", "LtxDim"), plain("A"), d("\u{2502}", "LtxDim"), plain("B"), d("\u{2502} \u{2514}\u{2500}\u{2500}\u{2534}\u{2500}\u{2500}\u{2518}", "LtxDim") }, "")
	entry("\\begin{tabularx}{..}{X|R}", {}, "tabularx")
	entry("\\toprule \\midrule \\bottomrule", { d("\u{2550}\u{2550}\u{2550}", "LtxDim"), plain(" data "), d("\u{2550}\u{2550}\u{2550}", "LtxDim") }, "booktabs")
	entry("\\hline  \\cline{1-2}", { d("\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}", "LtxDim") }, "")
	entry("\\multicolumn{2}{c}{text}", { d("\u{2190} merged cell \u{2192}", "LtxDim") }, "")
	entry("\\rowcolor{gray!20}", { d(" \u{2588}\u{2588}\u{2588} shaded row \u{2588}\u{2588}\u{2588} ", "LtxDim") }, "xcolor+colortbl")
	add("")

	header(9, "Math Mode")
	sep()
	entry("$...$  \\( ... \\)", { plain("inline: "), d("E = mc\u{00b2}", "LtxMath") }, "")
	entry("$$...$$  \\[ ... \\]", { plain("display: "), d("\u{2211}x\u{1d62} = n", "LtxMath") }, "")
	entry("\\begin{equation}", { d("(1)", "LtxDim"), plain("  "), d("a\u{00b2} + b\u{00b2} = c\u{00b2}", "LtxMath") }, "")
	entry("\\begin{equation*}", { plain("     "), d("a\u{00b2} + b\u{00b2} = c\u{00b2}", "LtxMath") }, "amsmath")
	entry("\\begin{align}", { d("(2)", "LtxDim"), plain("  "), d("x = y + z", "LtxMath") }, "amsmath")
	entry("\\begin{cases}", { d("f(x) = { 1 if x>0; 0 else", "LtxMath") }, "amsmath")
	add("")

	header(10, "Math Commands")
	sep()
	entry("\\frac{a}{b}  \\dfrac{}", { d("a", "LtxMath"), plain("/"), d("b", "LtxMath") }, "amsmath")
	entry("\\sqrt{x}  \\sqrt[n]{x}", { d("\u{221a}x", "LtxMath"), plain("  "), d("\u{207f}\u{221a}x", "LtxMath") }, "")
	entry("x^{2}  x_{i}", { d("x\u{00b2}", "LtxMath"), plain("  "), d("x\u{1d62}", "LtxMath") }, "")
	entry("\\sum_{i}^{n}  \\prod_{i}^{n}", { d("\u{2211}\u{1d62}\u{207f}", "LtxMath"), plain("  "), d("\u{220f}\u{1d62}\u{207f}", "LtxMath") }, "")
	entry("\\int_{a}^{b}  \\iint", { d("\u{222b}\u{1d43}\u{1d47}", "LtxMath"), plain("  "), d("\u{222c}", "LtxMath") }, "amsmath")
	entry("\\lim_{x \\to 0}", { d("lim", "LtxMath"), plain(" "), d("x\u{2192}0", "LtxDim") }, "")
	entry("\\hat{x}  \\bar{x}  \\vec{x}", { d("x\u{0302}", "LtxMath"), plain("  "), d("x\u{0304}", "LtxMath"), plain("  "), d("x\u{20d7}", "LtxMath") }, "")
	entry("\\mathbb{R}  \\mathcal{L}", { d("\u{211d}", "LtxMath"), plain("  "), d("\u{2112}", "LtxMath") }, "amssymb")
	add("")

	header(11, "Math Symbols")
	sep()
	entry("\\alpha \\beta \\gamma \\delta", { d("\u{03b1} \u{03b2} \u{03b3} \u{03b4}", "LtxMath") }, "")
	entry("\\epsilon \\theta \\lambda \\pi", { d("\u{03b5} \u{03b8} \u{03bb} \u{03c0}", "LtxMath") }, "")
	entry("\\sigma \\omega \\phi \\psi", { d("\u{03c3} \u{03c9} \u{03c6} \u{03c8}", "LtxMath") }, "")
	entry("\\infty \\partial \\nabla", { d("\u{221e} \u{2202} \u{2207}", "LtxMath") }, "")
	entry("\\leq \\geq \\neq \\approx", { d("\u{2264} \u{2265} \u{2260} \u{2248}", "LtxMath") }, "")
	entry("\\times \\cdot \\div \\pm", { d("\u{00d7} \u{00b7} \u{00f7} \u{00b1}", "LtxMath") }, "")
	entry("\\rightarrow \\Rightarrow", { d("\u{2192} \u{21d2} \u{2194}", "LtxMath") }, "")
	entry("\\forall \\exists \\in \\subset", { d("\u{2200} \u{2203} \u{2208} \u{2282}", "LtxMath") }, "")
	entry("\\implies \\iff \\therefore", { d("\u{27f9} \u{27fa} \u{2234}", "LtxMath") }, "amssymb")
	add("")

	header(12, "References & Citations")
	sep()
	entry("\\label{sec:x}  \\ref{sec:x}", { plain("see section "), d("3", "LtxLink") }, "")
	entry("\\pageref{sec:x}", { plain("page "), d("12", "LtxLink") }, "")
	entry("\\autoref{sec:x}", { d("Section 3", "LtxLink") }, "hyperref")
	entry("\\cite{key}", { d("[1]", "LtxDim") }, "")
	entry("\\textcite{key}", { d("Author [1]", "LtxDim") }, "biblatex")
	entry("\\parencite{key}", { d("(Author, 2024)", "LtxDim") }, "biblatex")
	entry("\\footnote{text}", { plain("text"), d("\u{00b9}", "LtxFootnote") }, "")
	add("")

	header(13, "Spacing & Layout")
	sep()
	entry("\\hspace{1cm}  \\vspace{1cm}", { plain("word"), d("     \u{2194}     ", "LtxDim"), plain("word") }, "")
	entry("\\hfill  \\vfill", { plain("left"), d("  \u{00b7}\u{00b7}\u{00b7}\u{00b7}\u{00b7}\u{00b7}\u{00b7}\u{00b7}\u{00b7}\u{00b7}  ", "LtxDim"), plain("right") }, "")
	entry("\\newpage  \\clearpage", { d("--- page break ---", "LtxDim") }, "")
	entry("\\noindent", { d("\u{2590}", "LtxDim"), plain("No indent paragraph") }, "")
	entry("\\usepackage[margin=..]{geometry}", {}, "geometry")
	add("")

	header(14, "Language & Fonts")
	sep()
	entry("\\setmainfont{Font Name}", { plain("Custom font face") }, "fontspec")
	entry("\\setdefaultlanguage{lang}", { plain("Hyphenation rules") }, "polyglossia")
	entry("\\usepackage[utf8]{inputenc}", {}, "inputenc")
	add("")

	header(15, "Drawings")
	sep()
	entry("\\begin{tikzpicture}", { d("\u{25cb}\u{2500}\u{2500}\u{25cb}\u{2500}\u{2500}\u{25b7}", "LtxMath") }, "tikz")
	entry("\\draw (0,0) -- (1,1);", { d("\u{2571}", "LtxMath"), plain(" line") }, "tikz")
	entry("\\node at (x,y) {text};", { d("\u{25a1}", "LtxMath"), plain(" labeled node") }, "tikz")
	add("")

	add("  [q/Esc] close")

	-- create buffer
	latex_cheatsheet_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(latex_cheatsheet_buf, 0, -1, false, lines)
	vim.bo[latex_cheatsheet_buf].bufhidden = "wipe"
	vim.bo[latex_cheatsheet_buf].filetype = "latex-cheatsheet"

	-- apply highlights
	local ns = vim.api.nvim_create_namespace("latex_cheatsheet")
	for _, m in ipairs(marks) do
		vim.api.nvim_buf_add_highlight(latex_cheatsheet_buf, ns, m[4], m[1], m[2], m[3])
	end
	vim.bo[latex_cheatsheet_buf].modifiable = false

	-- open window
	local ui = vim.api.nvim_list_uis()[1]
	local win_width = math.min(WIDTH + 2, ui.width - 4)
	local win_height = math.min(#lines, ui.height - 4)

	latex_cheatsheet_win = vim.api.nvim_open_win(latex_cheatsheet_buf, true, {
		relative = "editor",
		width = win_width,
		height = win_height,
		col = math.floor((ui.width - win_width) / 2),
		row = math.floor((ui.height - win_height) / 2),
		style = "minimal",
		border = "rounded",
		title = " LaTeX ",
		title_pos = "center",
	})

	vim.wo[latex_cheatsheet_win].winblend = 0
	vim.wo[latex_cheatsheet_win].cursorline = false

	local close_keys = { "q", "<Esc>", "<leader>?" }
	for _, key in ipairs(close_keys) do
		vim.keymap.set("n", key, close_latex_cheatsheet, { buffer = latex_cheatsheet_buf, nowait = true })
	end
end

vim.keymap.set("n", "<leader>?", open_latex_cheatsheet, { desc = "LaTeX cheat sheet" })

-- Prepend invoice template
vim.keymap.set("n", "<leader>it", function()
	if not ensure_modifiable() then
		return
	end
	local template = {
		"\\documentclass[a4paper,12pt]{article}",
		"\\usepackage[top=12mm,left=18mm,right=18mm,bottom=18mm]{geometry}",
		"\\usepackage{tabularx}",
		"\\usepackage{graphicx}",
		"\\usepackage{array}",
		"\\usepackage{fontspec}",
		"\\usepackage{polyglossia}",
		"\\setdefaultlanguage{romanian}",
		"",
		"\\newcolumntype{R}{>{\\raggedleft\\arraybackslash}X}",
		"",
		"\\begin{document}",
		"",
		"\\begin{tabularx}{\\linewidth}{X R}",
		"{{\\Large\\bfseries Lorem ipsum}\\par\\par } & {\\raggedleft\\includegraphics[height=3cm]{/home/mcr/notes/mimora_black.png}}\\\\",
		"& \\\\",
		"{\\bfseries FIRMA S.A.}\\par",
		"Adresa \\par",
		"\\hfill \\break",
		"CUI: \\par",
		"Reg.Com.: &",
		"",
		"\\par {\\bfseries MIMIRS NEXUS DEVELOPMENT S.R.L. }\\par",
		"Int. Gheorghe Simionescu 19, Bucuresti, Sector 1\\par",
		"CUI: 44922622\\par",
		"Reg.Com.: J40/16116/2021 \\par",
		"\\end{tabularx}",
		"",
		"\\end{document}",
	}
	vim.api.nvim_buf_set_lines(0, 0, 0, false, template)
end, { desc = "Prepend invoice template" })
