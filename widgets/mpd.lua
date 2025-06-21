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

local GET_MPD_CMD = "mpc status"
local TOGGLE_MPD_CMD = "mpc toggle"
local PAUSE_MPD_CMD = "mpc pause"
local STOP_MPD_CMD = "mpc stop"
local NEXT_MPD_CMD = "mpc next"
local PREV_MPD_CMD = "mpc prev"

local PATH_TO_ICONS = "/usr/share/icons/foo/"
local PAUSE_ICON_NAME = PATH_TO_ICONS .. "/24x24/actions/media-playback-pause-symbolic.symbolic.png"
local PLAY_ICON_NAME = PATH_TO_ICONS .. "/24x24/actions/media-playback-start-symbolic.symbolic.png"
local STOP_ICON_NAME = PATH_TO_ICONS .. "/24x24/actions/media-playback-stop-symbolic.symbolic.png"

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

local mpdarc_current_song_widget = wibox.widget {
    id = 'current_song',
    font = "Iosevka term " .. 10,
    widget = wibox.widget.textbox,
}

local update_graphic = function(widget, stdout, _, _, _)
    local current_song = string.gmatch(stdout, "[^\r\n]+")()
    stdout = string.gsub(stdout, "\n", "")
    local mpdpercent = string.match(stdout, "(%d%d)%%")
    local mpdstatus = string.match(stdout, "%[(%a+)%]")
    if mpdstatus == "playing" then
      icon.image = PLAY_ICON_NAME
      local fg = "#dddddd"
      mpdarc.colors = { fg }
      mpdarc_current_song_widget.text = current_song
      widget.fg = fg
    elseif mpdstatus == "paused" then
      icon.image = PAUSE_ICON_NAME
      local fg = "#555555"
      mpdarc.colors = { fg }
      mpdarc_current_song_widget.text = current_song
      widget.fg = fg
    else
      icon.image = STOP_ICON_NAME
      if string.len(stdout) == 0 then -- MPD is not running
        mpdarc_current_song_widget.text = "MPD is not running"
      else
        widget.colors = { beautiful.widget_red }
        mpdarc_current_song_widget.text = ""
      end
    end
end

local mpdarc_widget = wibox.container.background(wibox.widget{
  icon_margin,
  mpdarc_current_song_widget,
  layout = wibox.layout.align.horizontal,
}, "#00000000")



mpdarc_widget:connect_signal("button::press", function(_, _, _, button)
  if (button == 1) then awful.spawn(TOGGLE_MPD_CMD, false)      -- left click
  elseif (button == 2) then awful.spawn(STOP_MPD_CMD, false)
  elseif (button == 3) then awful.spawn(PAUSE_MPD_CMD, false)
  elseif (button == 4) then awful.spawn(NEXT_MPD_CMD, false)  -- scroll up
  elseif (button == 5) then awful.spawn(PREV_MPD_CMD, false)  -- scroll down
  end

  spawn.easy_async(GET_MPD_CMD, function(stdout, stderr, exitreason, exitcode)
      update_graphic(mpdarc_widget, stdout, stderr, exitreason, exitcode)
  end)
end)

watch(GET_MPD_CMD, 1, update_graphic, mpdarc_widget)

return mpdarc_widget
