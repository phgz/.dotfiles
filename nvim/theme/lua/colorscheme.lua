local dotfiles_path = os.getenv("HOME") .. "/.dotfiles"
local current_path = dotfiles_path .. "/theme/current"
local colorschemes_mapping = { night = "ayu-dark", day = "github_light", evening = "gruvbox-baby" }

local initialized = {}

local function reload()
	local current
	for line in io.lines(current_path) do
		current = line
	end
	if not vim.list_contains(initialized, current) then
		local colorFile = dotfiles_path .. "/nvim/theme/lua/" .. colorschemes_mapping[current] .. ".lua"
		vim.cmd("luafile " .. colorFile)
	end
	vim.cmd("colorscheme " .. colorschemes_mapping[current])
end

local w = vim.uv.new_fs_event()
local on_change
local function watch_file(fname)
	w:start(fname, {}, vim.schedule_wrap(on_change))
end
on_change = function()
	reload()
	-- Debounce: stop/start.
	w:stop()
	watch_file(current_path)
end
-- reload vim config when background changes
watch_file(current_path)
reload()
