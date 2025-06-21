local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local naughty = require("naughty")
require("math")

local GET_VOLUME_CMD = "pactl get-sink-volume @DEFAULT_SINK@"
local VOL_CHANGE_CMD = "pactl set-sink-volume @DEFAULT_SINK@ "
local GET_MUTE_CMD = "pactl get-sink-mute @DEFAULT_SINK@"
local TOGGLE_MUTE_CMD = "pactl set-sink-mute @DEFAULT_SINK@ toggle"

local current_volume
local bar = wibox.widget {
  max_value = 100,
  value = 0,
  forced_width = 20,
  forced_height = 5,
  border_width = 0,
  color = "#555555",
  background_color = "#000000",
  widget = wibox.widget.progressbar
}

local label = wibox.widget {
  text = "x",
  font = "Iosevka Term 10",
  align = "center",
  widget = wibox.widget.textbox
}

local bar_and_label = wibox.widget {
  {
    nil,
    bar,
    nil,
    layout = wibox.layout.align.vertical
  },
  {
    label,
    fg = "#FFFFFF",
    widget = wibox.container.background
  },
  layout = wibox.layout.stack
}

local update_graphic = function(widget, volout, muteout)
    local volume = string.match(volout, "(%d+)%%")
    local mute = string.match(muteout, "yes")
    if mute then
      label.text = "[" .. volume .. "%]"
    else
      label.text = " " .. volume .. "% "
    end
    current_volume = tonumber(volume)
    bar.value = current_volume
end


local got_volupdate = function(bar_and_label, volout, stderr, exitreason, exitcode)
    spawn.easy_async(GET_MUTE_CMD, function(mutout, stderr, exitreason, exitcode)
      update_graphic(bar_and_label, volout, mutout)
    end)
end

local do_volume_up = function()
  if current_volume > 100 then
    awful.spawn(VOL_CHANGE_CMD .. "100%", false)
  elseif current_volume == 100 then
    -- do nothing!
  else
    local next_volume = current_volume + 5
    next_volume = math.min(next_volume, 100)
    awful.spawn(VOL_CHANGE_CMD .. next_volume .. "%", false)
  end
end

local do_volume_down = function()
  if current_volume < 0 then
    -- should never happen but might as well cover it
    awful.spawn(VOL_CHANGE_CMD .. "0%", false)
  elseif current_volume == 0 then
    -- do nothing!
  else
    local next_volume = current_volume - 5
    next_volume = math.max(next_volume, 0)
    awful.spawn(VOL_CHANGE_CMD .. next_volume .. "%", false)
  end
end



bar_and_label:connect_signal("button::press", function(_, _, _, button)
  if (button == 1) then awful.spawn(TOGGLE_MUTE_CMD, false)      -- left click
  -- elseif (button == 2) then awful.spawn(STOP_MPD_CMD, false)
  -- elseif (button == 3) then awful.spawn(PAUSE_MPD_CMD, false)
  elseif (button == 4) then do_volume_up()
  elseif (button == 5) then do_volume_down()
  end

  spawn.easy_async(GET_VOLUME_CMD, function (stdout, stderr, exitreason, exitcode)
    got_volupdate(bar_and_label, stdout, stderr, exiteason, exitcode)
  end)
end)

watch(GET_VOLUME_CMD, 1, got_volupdate, bar_and_label)

return bar_and_label
