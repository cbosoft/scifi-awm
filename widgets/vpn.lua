local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
require("math")

local function octagon_with_flair(cr, width, height)
  local radius = 20
  cr:move_to(radius, 0)
  cr:line_to(width/3, 0)
  cr:line_to(width/3 + radius, radius)
  cr:line_to(width - radius, radius)
  cr:line_to(width, 2*radius)
  cr:line_to(width, height - radius)
  cr:line_to(width - radius, height)
  cr:line_to(2*radius, height)
  cr:line_to(0, height - 2*radius)
  cr:line_to(0, radius)
  cr:close_path()
end

local VPN = { mt = {}, wmt = {} }
VPN.wmt.__index = VPN
VPN.__index = VPN

config = awful.util.getdir("config")

local function trim(s)
   return s:match "^%s*(.-)%s*$"
end


local popup_text_widget = wibox.widget {
  widget = wibox.widget.textbox,
  text   = '--',
  font = 'Iosevka Term 10',
}

local popup = awful.popup {
  widget = {
    {
      {
        popup_text_widget,
        bg     = '#000000',
        fg     = '#dddddd',
        -- forced_width = 200,
        -- forced_height = 50,
        widget = wibox.widget.background
      },
      layout = wibox.layout.fixed.vertical,
    },
    margins = 50,
    widget  = wibox.container.margin
  },
  border_color = '#dddddd',
  border_width = 2,
  placement    = awful.placement.centered,
  shape        = octagon_with_flair,
  shape_clip = true,
  visible      = false,
  ontop = true,
}


local status_text_widget = wibox.widget {
  widget = wibox.widget.textbox,
  text   = 'vpn',
  font = 'Iosevka Term 10',
}

local status_widget = wibox.widget {
  status_text_widget,
  bg     = '#000000',
  fg     = '#dddddd',
  widget = wibox.widget.background
}


local function run(command)
	local prog = io.popen(command)
	local result = prog:read('*all')
	prog:close()
	return trim(result)
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
	obj.widget = status_widget
  obj.widget:buttons(gears.table.join(
    awful.button({ }, 1, function() obj:toggle() end)))

	-- Check every 5 seconds
	obj.timer = timer({timeout = 5})
	obj.timer:connect_signal("timeout", function() obj:update({}) end)
	obj.timer:start()

	obj:update({})

	return obj
end

function VPN:update()
	local status = run("/home/chris/.bin/vpn status")
  local is_active = string.match(status, "off") == nil
  popup_text_widget.text = status

  if is_active then
    status_text_widget.text = "VPN active"
    status_widget.fg = "#dddddd"
  else
    status_text_widget.text = "VPN offline"
    status_widget.fg = "#555555"
  end
end

function VPN:toggle()
	local status = run("/home/chris/.bin/vpn toggle")
	self:update()
end

function VPN.mt:__call(...)
	return VPN.new(...)
end

status_widget:connect_signal("mouse::enter", function()
  popup.visible = true
end)

status_widget:connect_signal("mouse::leave", function()
  popup.visible = false
end)

return VPN
