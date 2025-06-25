-------------------------------------------------
-- mpd Arc Widget for Awesome Window Manager
-- Modelled after Pavel Makhov's work

-- @author Raphaël Fournier-S'niehotta
-- @copyright 2018 Raphaël Fournier-S'niehotta
-------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local naughty = require("naughty")
local gears = require("gears")

local GET_MPD_CMD = "mpc status"
local TOGGLE_MPD_CMD = "mpc toggle"
local PAUSE_MPD_CMD = "mpc pause"
local STOP_MPD_CMD = "mpc stop"
local NEXT_MPD_CMD = "mpc next"
local PREV_MPD_CMD = "mpc prev"
local OPEN_NCMPCPP_CMD = "kitty --class FLOATME ncmpcpp"

local PATH_TO_ICONS = "/usr/share/icons/foo/"
local PAUSE_ICON_NAME = PATH_TO_ICONS .. "/24x24/actions/media-playback-pause-symbolic.symbolic.png"
local PLAY_ICON_NAME = PATH_TO_ICONS .. "/24x24/actions/media-playback-start-symbolic.symbolic.png"
local STOP_ICON_NAME = PATH_TO_ICONS .. "/24x24/actions/media-playback-stop-symbolic.symbolic.png"


local function trim(s)
   return s:match "^%s*(.-)%s*$"
end

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


local icon = wibox.widget {
        id = "icon",
        widget = wibox.widget.imagebox,
        image = PLAY_ICON_NAME
    }
local mirrored_icon = wibox.container.mirror(icon, { horizontal = true })


local mpdarc = wibox.widget {
    mirrored_icon,
    max_value = 1,
    value = 1,
    thickness = 3,
    start_angle = 0,
    forced_height = 24,
    forced_width = 24,
    rounded_edge = true,
    paddings = 2,
    widget = wibox.container.arcchart
}

local icon_margin = wibox.container.margin(mpdarc, 0, 5)

local mpd_status_widget = wibox.widget {
    id = 'current_status',
    text = 'n/a',
    font = "Iosevka term " .. 10,
    widget = wibox.widget.textbox,
}

local function parse_mpd_status(stdout)
  local current_song = string.gmatch(stdout, "[^\r\n]+")()
  stdout = string.gsub(stdout, "\n", "")
  local mpdpercent = string.match(stdout, "(%d%d)%%")
  local mpdstatus = string.match(stdout, "%[(%a+)%]")
  return { running = string.len(stdout) > 0, song = current_song, perc = mpdpercent, status = trim(mpdstatus) }
end


local mpd_widget = wibox.container.background(wibox.widget{
  mpd_status_widget,
  layout = wibox.layout.align.horizontal,
}, "#00000000")

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


local update_graphic = function(widget, stdout, _, _, _)
  local mpd = parse_mpd_status(stdout)
  local fg = "#dddddd"

  if mpd.status == "playing" then
    mpd_status_widget.text = mpd.status
  elseif mpd.status == "paused" then
    mpd_status_widget.text = mpd.status
    fg = "#555555"
  else
    if not mpd.running then
      mpd_status_widget.text = "MPD is not running"
    else
      fg = beautiful.widget_red
      mpd_status_widget.text = "Error" .. mpd.status
    end
  end
  widget.fg = fg

  popup_text_widget.text = stdout
end


mpd_widget:connect_signal("button::press", function(_, _, _, button)
  if (button == 1) then awful.spawn(OPEN_NCMPCPP_CMD, false)      -- left click
  elseif (button == 2) then awful.spawn(STOP_MPD_CMD, false)
  elseif (button == 3) then awful.spawn(TOGGLE_MPD_CMD, false)
  elseif (button == 4) then awful.spawn(NEXT_MPD_CMD, false)  -- scroll up
  elseif (button == 5) then awful.spawn(PREV_MPD_CMD, false)  -- scroll down
  end

  spawn.easy_async(GET_MPD_CMD, function(stdout, stderr, exitreason, exitcode)
      update_graphic(mpd_widget, stdout, stderr, exitreason, exitcode)
  end)
end)

mpd_widget:connect_signal("mouse::enter", function()
  popup.visible = true
end)

mpd_widget:connect_signal("mouse::leave", function()
  popup.visible = false
end)

watch(GET_MPD_CMD, 1, update_graphic, mpd_widget)

return mpd_widget
