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

local activewin = nil -- activewin
local activeidx = nil -- display cursor
local idx = 0 -- real cursor
local files = {} -- id: tempfile
local fileindex = {} -- id: path

local module = {
	meta = generate_meta("tabview", "1.0.0"),
	events = {
		TAB_OPEN = "tab_open", -- tab_open(filename)
		TAB_REPLACE = "tab_replace", -- tab_replace(filename, idx)
		TAB_CLOSE = "tab_close" -- tab_close(idx)
	}
}

local function showcount()
	vis:info("Opened tabs: " .. #files)
end
local function opentab(index)
	if #fileindex == 1 then return end
	if index ~= nil then idx = index - 1 end
	if activeidx ~= nil then
		files[activeidx + 1]:close()
		files[activeidx + 1] = io.tmpfile()
		files[activeidx + 1]:write(activewin.file:content(0, activewin.file.size))
	end
	activewin.file = fileindex[idx + 1]
	activewin.file:delete(0, activewin.file.size)
--	vis:info("path: " .. fileindex[idx + 1])
	local temp = files[idx + 1]
	temp:seek("set", 0)
	local text = temp:read("*a")
	activewin.file:insert(0, text)
	activeidx = idx
end
local function closetab(index)
	if #fileindex == 1 then
		vis:exit(0)
	end
	if index ~= nil then
		files[index]:close()
		table.remove(fileindex, idx)
		table.remove(files, idx)
		if idx >= index then idx = idx - 1 end
	else
		files[idx + 1]:close()
		table.remove(fileindex, idx + 1)
		table.remove(files, idx + 1)
		idx = idx - 1
	end
	opentab()
end
local function replacetab(index, filename)
	if index == nil or index <= 0 or index > #fileindex then
		return
	end
	files[index]:close()
	fileindex[index] = nil
	files[index] = nil
	if filename == nil then
		vis:command("new")
	else 
		vis:command("open " .. filename)
	end
	local win = vis.win
	local file = win.file
	local path = file.path
	local temp = io.tmpfile()
	temp:write(file:content(0, file.size))
	vis:close(win)
	fileindex[index] = path
	files[index] = temp
	opentab()
end
local function nexttab()
	idx = (idx + 1) % #fileindex
end
local function prevtab()
	idx = (idx - 1) % #fileindex
end

local function storefile(file)
	local tmpfile = io.tmpfile()
	tmpfile:write(file:content(0, file.size))
	fileindex[#fileindex + 1] = file.path
	files[#fileindex] = tmpfile
--	vis:info("Tabs: " .. #fileindex)
end
local function findfile(filename)
	for idx = 1, #fileindex do
		if fileindex[idx] == filename then
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
		if win == activewin then
			win:close()
		end
		opentab(#fileindex)
		return true
	end, 1)
	vis.events.subscribe(module.events.TAB_REPLACE, function(index, filename)
		replacetab(index, filename)
	end, 1)
	vis.events.subscribe(module.events.TAB_CLOSE, function(index)
		closetab(index)
	end, 1)
	vis.events.subscribe(vis.events.WIN_CLOSE, function(win) 
		if win == activewin then
			activewin = nil
		end
		if win == activewin and win ~= nil then
			return true
		end
	end, 1)
	vis.events.subscribe(vis.events.WIN_OPEN, function(win)
		if win == nil then
			return false
		end
		if activewin == nil then
			storefile(win.file)
			activewin = win
			return true
		end
		if win == activewin then
			vis:info("It's already active window")
			return false
		end
		if win.owner == nil then return false end
		if win.owner ~= "tabview" then
			storefile(win.file)
			activewin.file = win.file
			win:close()
		end
	end)
end
function module.get_tab_name_at(index)
	if index ~= nil and index > 0 and index <= #fileindex then
		return fileindex[index]
	end
	return "nil"
end
function module.get_active_tab()
	return activeidx
end
function module.get_tab_count()
	return #fileindex
end
function module.active_window()
	return activewin
end
-- If index == nil then open new tab
function module.tab_open(filename, index)
	if index ~= nil then
		vis.events.emit(module.events.TAB_REPLACE, index, filename)
	else
		vis.events.emit(module.events.TAB_OPEN, filename)
	end
end
function module.tab_close(arg) -- if arg is number it just
	local index = nil
	if type(arg) == "string" then
		index = findfile(arg)
	elseif type(arg) == "number" then index = arg
	else
		vis.events.emit(module.events.TAB_CLOSE)
		return
	end
	vis.events.emit(module.events.TAB_CLOSE, index)
end
function module.terminate()
	for i = 1,#fileindex do
		vis:message("File " .. fileindex[i] .. "Closing")
		files[fileindex[i]]:close()
	end
end

return module
