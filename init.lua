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
	index = {} -- id: {name, path}
}

local function showcount()
	vis:info("Opened tabs: " .. #module.files)
end
local function opentab()
	if #module.index == 1 then return end
	module.win.file = module.index[module.idx + 1].path
	vis:info("path: " .. module.index[module.idx + 1].path)
	local temp = module.files[module.idx + 1]
	temp:seek("set", 0)
	local text = temp:read("*a")
	module.win.file:insert(0, text)
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
	module.index[#module.index + 1] = {
		name = file.name,
		path = file.path
	}
	module.files[#module.index] = tmpfile
	vis:info("Tabs: " .. #module.index)
end
function module.init()
	vis:command_register("tabcount", function() showcount() end)
	vis:command_register("nexttab", function()
		nexttab()
		opentab()
	end)
	vis:command_register("prevtab", function()
		prevtab()
		opentab()
	end)
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
function module.terminate()
	for i = 1,#module.index do
		vis:message("File " .. module.index[i] .. "Closing")
		module.files[module.index[i]]:close()
	end
end

return module