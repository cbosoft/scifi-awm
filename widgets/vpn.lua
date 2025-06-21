local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
require("math")

local VPN = { mt = {}, wmt = {} }
VPN.wmt.__index = VPN
VPN.__index = VPN

config = awful.util.getdir("config")


local function run(command)
	local prog = io.popen(command)
	local result = prog:read('*all')
	prog:close()
	return result
end


local function round(num)
	if num - math.floor(num) >= 0.5 then
		return math.floor(num)+1
	else
		return math.floor(num)
	end
end


function VPN:new(args)
	local obj = setmetatable({}, VPN)

	-- Create imagebox widget
	obj.widget = wibox.widget.textbox()
	obj.widget.text = "vpn"
  obj.widget.font = "Iosevka Term " .. beautiful.corner_radius*3/4
  obj.widget:buttons(gears.table.join(
    awful.button({ }, 1, function() obj:toggle() end)))

	-- Check every 5 seconds
	obj.timer = timer({timeout = 5})
	obj.timer:connect_signal("timeout", function() obj:update({}) end)
	obj.timer:start()

	obj:update({})

	return obj
end

function VPN:update(status)
  self.widget.text = self.getStatus()
end

function VPN:getStatus()
	return run("/home/chris/.bin/vpn status")
end

function VPN:toggle()
	local status = run("/home/chris/.bin/vpn toggle")
	self:update()
end

function VPN.mt:__call(...)
	return VPN.new(...)
end

return VPN
