--[[
AUTHOR: stalker32021 (also known as stalker57241)
DESCRIPTION: Allows to store data in several tabs
--]]

local vis = _G.vis

local env, mt = {}, {
	__index = _G,
	__newindex = function()
		error("Error: runaway assignment on tabview module", 2)
	end
}
local _ENV = setmetatable(env, mt)

local module = {
	win = nil,
	idx = 0,
	files = {}, -- id: tempfile
	index = {}, -- id: path
	events = {
		TAB_OPEN = "tab_open",
		TAB_CLOSE = "tab_close"
	}
}

local function showcount()
	vis:info("Opened tabs: " .. #module.files)
end
local function opentab(idx)
	if #module.index == 1 then return end
	if idx ~= nil then module.idx = idx - 1 end
	module.win.file = module.index[module.idx + 1]
	module.win.file:delete(0, module.win.file.size)
	vis:info("path: " .. module.index[module.idx + 1])
	local temp = module.files[module.idx + 1]
	temp:seek("set", 0)
	local text = temp:read("*a")
	module.win.file:insert(0, text)
end
local function closetab(idx)
	if #module.index == 1 then
		vis:exit(0)
	end
	if idx ~= nil then
		module.files[idx]:close()
		table.remove(module.index, idx)
		table.remove(module.files, idx)
		if module.idx >= idx then module.idx = module.idx - 1 end
	else
		module.files[module.idx + 1]:close()
		table.remove(module.index, module.idx + 1)
		table.remove(module.files, module.idx + 1)
		module.idx = module.idx - 1
	end
	opentab()
end
local function nexttab()
	module.idx = (module.idx + 1) % #module.index
end
local function prevtab()
	module.idx = (module.idx - 1) % #module.index
end

local function storefile(file)
	local tmpfile = io.tmpfile()
	tmpfile:write(file:content(0, file.size))
	module.index[#module.index + 1] = file.path
	module.files[#module.index] = tmpfile
	vis:info("Tabs: " .. #module.index)
end
local function findfile(filename)
	for idx = 1, #module.index do
		if module.index[idx] == filename then
			return idx
		end
	end
	return nil
end
local function openfile(filename)
	local idx = findfile(filename)
	if idx == nil then return false end
	opentab(idx)
	return true
end
function module.init()
	vis:command_register("tabcount", function() showcount() end)
	vis:command_register("closetab", function() closetab() end)
	vis:command_register("nexttab", function()
		nexttab()
		opentab()
	end)
	vis:command_register("prevtab", function()
		prevtab()
		opentab()
	end)
	vis.events.subscribe(module.events.TAB_OPEN, function(filename) 
		if openfile(filename) then return end
		vis:command("open " .. filename)
		local win = vis.win
		storefile(win.file)
		win:close()
		opentab(#module.index)
		return true
	end, 1)
	vis.events.subscribe(module.events.TAB_CLOSE, function(idx)
		closetab(idx)
	end, 1)
	vis.events.subscribe(vis.events.WIN_CLOSE, function(win) if win == module.win and win ~= nil then return true end end, 1)
	vis.events.subscribe(vis.events.WIN_OPEN, function(win)
		if win == nil then
			return false
		end
		if module.win == nil then
			storefile(win.file)
			module.win = win
			return true
		end
		if win == module.win then
			vis:info("It's already active window")
			return false
		end
		if win.owner == nil then return false end
		if win.owner ~= "tabview" then
			storefile(win.file)
			module.win.file = win.file
			win:close()
--			vis:info("Tab added: " .. module.win.file.name)
		end
	end)
end
function module.tab_open(filename)
	vis.events.emit(module.events.TAB_OPEN, filename)
end
function module.tab_close(arg) -- if arg is number it just
	local idx = nil
	if type(arg) == "string" then
		idx = findfile(arg)
	elseif type(arg) == "number" then idx = arg
	else
		vis.events.emit(module.events.TAB_CLOSE)
		return
	end
	vis.events.emit(module.events.TAB_CLOSE, idx)
end
function module.terminate()
	for i = 1,#module.index do
		vis:message("File " .. module.index[i] .. "Closing")
		module.files[module.index[i]]:close()
	end
end

return module
