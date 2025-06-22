local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local awful = require("awful")
require("math")

local Battery = { mt = {}, wmt = {} }
Battery.wmt.__index = Battery
Battery.__index = Battery

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
	

function Battery:new(args)
	local obj = setmetatable({}, Battery)

	obj.batteryDir = args.batteryDir or "/sys/class/power_supply/"
	obj.battery = args.battery or "BAT0"
	obj.capacityFile = args.capacityFile or "capacity"
	obj.statusFile = args.statusFile or "status"
	obj.isChargingIndicator = args.isChargingIndicator or "Charging"

	-- Create imagebox widget
	obj.widget = wibox.widget.textbox()
	obj.widget.markup = ""
  obj.widget.font = "Iosevka Term 10"

	-- Check battery level every 5 seconds
	obj.timer = timer({timeout = 5})
	obj.timer:connect_signal("timeout", function() obj:update({}) end)
	obj.timer:start()

	obj:update({})

	return obj
end

function Battery:update(status)
	local perc = self:getCapacity()
	local style = ""
	if perc > 95 then
		-- do nothing
  elseif self:getCharging()  then
		style = "color=\"yellow\" "
  else
    if perc < 10 then
		  style = "color=\"red\" weight=\"heavy\" "
      naughty.notify { 
        preset = naughty.config.presets.critical,
        title = "BATTERY LOW!",
        text = "Charge soon or lose your work!",
        timeout = 4
      }
    end
	end
  self.widget.markup = "<span " .. style .. ">" .. perc .. "%</span>"
end

function Battery:getCapacity()
	return tonumber(run("cat "..self.batteryDir..self.battery.."/"..self.capacityFile))
end

function Battery:getCharging()
	local status = run("cat "..self.batteryDir..self.battery.."/"..self.statusFile)
	if status:find("Charging") ~= nil then
		return true
	end
	return false
end

function Battery.mt:__call(...)
	return Battery.new(...)
end

return Battery
