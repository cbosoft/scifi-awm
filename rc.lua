pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- Widgets
local my_widgets = require("widgets")

-- {{{ Layouts
local my_layouts = require('layouts');
-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    -- awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    -- my_layouts.test,
    -- my_layouts.aesth,
    my_layouts.thirds,
    my_layouts.monkeys,
}

-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.useless_gap = 10
beautiful.wallpaper = "/home/chris/.wallpaper"
beautiful.border_width = 4
beautiful.corner_radius = 15
beautiful.border_normal = "#555555"
beautiful.border_focus = "#cccccc"
-- beautiful.border_focus = "#EF4A81" -- too candy
-- beautiful.border_focus = "#D600FF"
-- beautiful.border_focus = "#001EFF"
beautiful.taglist_font = "Iosevka Term 10"
beautiful.taglist_fg_focus = "#ddd"
beautiful.taglist_fg = "#ffff00"
beautiful.taglist_bg_focus = "#000000"
beautiful.taglist_shape_border_width_focus = 2
beautiful.taglist_shape_border_width_focus = 2
beautiful.taglist_shape_border_color_focus = "#dddddd"
beautiful.taglist_shape_border_color = "#555555"


-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
mytextclock.font = "Iosevka Term " .. beautiful.corner_radius * 3/4


function get_pid_usage(p)
  return { 0, 0 }
end

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
                              if client.focus then
                                  client.focus:move_to_tag(t)
                              end
                          end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
                              if client.focus then
                                  client.focus:toggle_tag(t)
                              end
                          end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local battery = my_widgets.Battery:new({})
local vpn = my_widgets.VPN:new({})

function map(arr, f)
  local out = {}
  for i = 1, #arr do
    out[i] = f(arr[i])
  end
  return out
end


-- Define a simple octagon shape
local function octagon(cr, width, height, radius)
    cr:move_to(radius, 0)
    cr:line_to(width - radius, 0)
    cr:line_to(width, radius)
    cr:line_to(width, height - radius)
    cr:line_to(width - radius, height)
    cr:line_to(radius, height)
    cr:line_to(0, height - radius)
    cr:line_to(0, radius)
    cr:close_path()
end

local function octagon_with_flair(cr, width, height, radius)
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
local function b_octagon(cr, width, height, radius)
    radius = radius or h/4
    -- cr:move_to(0, 0)
    -- cr:line_to(width, 0)
    cr:move_to(width, 0)
    cr:line_to(width, height - radius)
    cr:line_to(width - radius, height)
    cr:line_to(radius, height)
    cr:line_to(0, height-radius)
    cr:line_to(0, 0)
    -- cr:close_path()
end
local function br_octagon(cr, width, height)
    radius = height // 3
    cr:move_to(width, 0)
    cr:line_to(width, height - radius)
    cr:line_to(width - radius, height)
    cr:line_to(0, height)
end
local function r_octagon(cr, width, height)
    radius = height // 3
    cr:move_to(width, 0)
    cr:line_to(width, height - radius)
    cr:line_to(width - radius, height)
end
local function bl_octagon(cr, width, height)
    radius = height // 3
    cr:move_to(0, 0)
    cr:line_to(0, height - radius)
    cr:line_to(radius, height)
    cr:line_to(width, height)
end



awful.screen.connect_for_each_screen(function(s)
  naughty.notify { text = s.index .. ":" .. s.index }
    -- Wallpaper
    set_wallpaper(s)
    local function clients_for_tag(t)
      local clients_on_tag = {}
      for _, c in pairs(s.all_clients) do
        for _, tag in pairs(c:tags()) do
           if tag == t then
             table.insert(clients_on_tag, c)
             break
           end
        end
      end
      return clients_on_tag
    end

    local function icon_for_tag(t)
      local icons = {
        { rule = { class = "kitty" }, icon = "terminal-solid.png" },
        { rule = { name = "^Microsoft Teams", class = "Google-chrome" }, icon = "comment-solid.png" },
        { rule = { name = "^Outlook", class = "Google-chrome" }, icon = "envelope-solid.png" },
        { rule = { class = "Google-chrome" }, icon = "globe-solid.png" },
        { rule = { class = "obsidian" }, icon = "file-pen-solid.png" },
      }
      local clients = clients_for_tag(t)
      for _, icon_rule in ipairs(icons) do
        for _, c in ipairs(clients) do
          if awful.rules.match(c, icon_rule.rule) then
            return config .. "/icons/" .. icon_rule.icon
          end
        end
      end
      return nil
    end

    local function do_update_tagicon(widget, t, i, ts)
      local icon = widget:get_children_by_id('my_icon_role')[1]
      local icon_name = icon_for_tag(t)
      icon.image = icon_name
      if t.selected then
        icon.opacity = 0.9
      else
        icon.opacity = 0.5
      end
      local name = t.name
      if icon_name ~= nil then
        name = name .. ":/"
      end
      local prefix = ""
      local suffix = ""
      if t.selected then
        prefix = "<b>"
        suffix = "</b>"
      end
      widget:get_children_by_id('index_role')[1].markup = prefix .. name .. suffix
    end

    local function update_tagicon(widget, t, i, ts)
      -- no errors please and thank you.
      pcall(function()
        do_update_tagicon(widget, t, i, ts)
      end)
    end


    -- Each screen has its own tag table.
    awful.tag(
      { "1", "2", "3", "4", "5", "6", "7", "8", "9", "A" },
      s,
      awful.layout.layouts[1]
    )

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        layout   = {
            spacing = 5,
            layout  = wibox.layout.fixed.horizontal
        },
        style = {
          shape = r_octagon,
          shape_border_width = 2,
          -- shape_border_color = "#dddddd"
        },
        widget_template = {
            {
                {
                    {
                      id     = 'index_role',
                      markup = "x",
                      widget = wibox.widget.textbox,
                    },
                    {
                      {
                        id     = 'my_icon_role',
                        widget = wibox.widget.imagebox,
                        opacity = 0.75,
                      },
                      margins = 5,
                      widget  = wibox.container.margin,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 0,
                right = 0,
                widget = wibox.container.margin,
            },
            id = 'background_role',
            -- shape = br_octagon,
            -- shape_border_width = 1,
            -- shape_border_color = "#333333",
            widget = wibox.container.background,
            create_callback = update_tagicon,
            update_callback = update_tagicon,
            forced_width = 50,
        },
    }

    -- Create a tasklist widget
    -- s.mytasklist = awful.widget.tasklist {
    --     screen  = s,
    --     filter  = awful.widget.tasklist.filter.currenttags,
    --     buttons = tasklist_buttons
    -- }

    function wrap_shape(w, shape)
      return {
        widget = wibox.container.background,
        shape = shape,
        shape_border_width = 2,
        shape_border_color = "#777777",
        --shape_clip = true,
        {
          widget = wibox.container.margin,
          left = 15,
          right = 15,
          w,
        }
      }
    end

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, bg = "#ffffff00", fg = "#ddd", height = 30 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
          widget = wibox.container.background,
          shape = function (cr, w, h) br_octagon(cr, w, h) end,
          shape_border_width = 2,
          shape_border_color = "#dddddd",
          {
            widget = wibox.container.margin,
            right = 15,
            {
              layout = wibox.layout.fixed.horizontal,
              spacing = 10,
              s.mytaglist,
              {
                {
                  {
                    widget = wibox.widget.textbox,
                    text = "SCR:/" .. s.index .. "/",
                    font = "Iosevka Term 10",
                  },
                  widget = wibox.container.margin,
                  left = 5,
                  right = 5,
                },
                widget = wibox.container.background,
                fg = "#bbbbbb",
              },
              s.mypromptbox,
            }
          }
        },
        nil,
        {
          widget = wibox.container.background,
          shape = function (cr, w, h) bl_octagon(cr, w, h) end,
          shape_border_width = 2,
          shape_border_color = "#dddddd",
          {
            widget = wibox.container.margin,
            left = 15,
            {
              layout = wibox.layout.fixed.horizontal,
              spacing = 0,
              wibox.widget.systray(),
              wrap_shape(my_widgets.volume, bl_octagon),
              wrap_shape(my_widgets.mpd, bl_octagon),
              wrap_shape(battery.widget, bl_octagon),
              wrap_shape(vpn.widget, bl_octagon),
              wrap_shape(mytextclock, bl_octagon),
              -- wrap_shape(s.mylayoutbox, bl_octagon),
            }
          }
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    -- awful.key({ modkey,           }, "Left",   awful.tag.viewprev, {description = "view previous", group = "tag"}),
    -- awful.key({ modkey,           }, "Right",  awful.tag.viewnext, {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "`", awful.tag.history.restore, {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "Left", function () awful.client.focus.byidx( 1) end, {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "Right", function () awful.client.focus.byidx(-1) end, {description = "focus previous by index", group = "client"}),
    -- awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    --           {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx(  1)    end, {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx( -1)    end, {description = "swap with previous client by index", group = "client"}),
    -- awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end, {description = "focus the next screen", group = "screen"}),
    -- awful.key({ modkey,           }, "Tab", function () awful.screen.focus_relative(-1) end, {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),
    -- awful.key({ modkey,           }, "Tab", function () awful.client.focus.history.previous() if client.focus then client.focus:raise() end end, {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "z", function () awful.spawn(terminal) end, {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "w", function () awful.spawn("google-chrome") end, {description = "open a browser", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "s", function () awful.spawn.with_shell("/home/chris/.bin/scrput") end, {description = "rejig screens", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "a", function () awful.spawn.with_shell("lsotp get test | xclip -selection clipboard") end, {description = "lsotp", group = "launcher"}),

    -- Media keys
    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn("mpc toggle") end, { description = "Music toggle", group = "media"} ),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn("mpc next") end, { description = "Music next", group = "media" }),
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("mpc prev") end, { description = "Music prev", group = "media" }),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end, { description = "Volume up", group = "media" }),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end, { description = "Volume down", group = "media" }),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end, { description = "Volume mute toggle", group = "media" }),

    awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("brightnessctl set '10%-'") end, { description = "Brightness down", group = "power" }),
    awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn("brightnessctl set '10%+'") end, { description = "Brightness up", group = "power" }),

    awful.key({ modkey, "Control" }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
    --awful.key({ modkey,  }, "r", awful.rules.reload, {description = "rerun rules", group = "awesome"}),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end, {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end, {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end, {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end, {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end, {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end, {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "]",     function () awful.layout.inc( 1) end, {description = "select next", group = "layout"}),
    awful.key({ modkey,           }, "[",     function () awful.layout.inc(-1) end, {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "space",     function () awful.spawn("rofi -show combi") end, {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen c:raise() end, {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill() end, {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle, {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen() end, {description = "move to screen", group = "client"}),
    -- awful.key({ modkey,           }, "r",      function (c) awful.rules:apply(c) end, {description = "re-run rules on client", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end, {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n", function (c) c.minimized = true end , {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m", function (c) c.maximized = not c.maximized c:raise() end , {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m", function (c) c.maximized_vertical = not c.maximized_vertical c:raise() end , {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m", function (c) c.maximized_horizontal = not c.maximized_horizontal c:raise() end , {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    local j = i % 10;
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "" .. j,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..j, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "" .. j,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. j, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "" .. j,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..j, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "" .. j,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. j, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = { class = { "cantata", "Sido", "matplotlib" }, name = { "Picture-in-picture" }, }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" } }, properties = { titlebars_enabled = true } },
    { rule_any = {type = { "dialog" }, class = { "matplotlib" } }, properties = { placement = awful.placement.centered } },

    -- Add windows to specific screens/tags
    { rule = { class = "Google-chrome" }, properties = { screen = screen.primary, tag = screen.primary.tags[3], } },
    { rule = { name = "^Microsoft Teams.*", class = "Google-chrome" }, properties = { screen = screen.primary, tag = screen.primary.tags[2], floating = false } },
    { rule = { class = "obsidian" }, properties = { screen = screen.primary, tag = screen.primary.tags[9], floating = false } },
    { rule = { name = "^Outlook.*", class = "Google-chrome" }, properties = { screen = screen.primary, tag = screen.primary.tags[10], floating = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    c.shape = function(cr,w,h)
        octagon_with_flair(cr, w, h, beautiful.corner_radius)
    end
end)

client.connect_signal("property::floating", function (c)
  if c.fullscreen or c.maximized then
    c.shape = gears.shape.rectangle
  else
    c.shape = function(cr, w, h)
      octagon_with_flair(cr, w, h, beautiful.corner_radius)
    end
  end
end)


-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)

    c.cmw = my_widgets.CMW:new(c.pid, c.window);

    -- -- buttons for the titlebar
    -- local buttons = gears.table.join(
    --     awful.button({ }, 1, function()
    --         c:emit_signal("request::activate", "titlebar", {raise = true})
    --         awful.mouse.client.move(c)
    --     end),
    --     awful.button({ }, 3, function()
    --         c:emit_signal("request::activate", "titlebar", {raise = true})
    --         awful.mouse.client.resize(c)
    --     end)
    -- )

    awful.titlebar(c, { position = "top", size = beautiful.corner_radius } ) : setup {
      { 
        {
          left  = beautiful.corner_radius,
          widget = wibox.container.margin,
          c.cmw.overview,
        },
        layout = wibox.layout.fixed.horizontal
      },
      bg = "#000000",
      widget = wibox.container.background
    }

    local title_layout = {
      {
        widget = wibox.container.rotate,
        direction = "east",  -- or "west" for counter-clockwise
        {
          right  = beautiful.corner_radius,
          widget = wibox.container.margin,
          {
            c.cmw.bar,
            {
              widget = awful.titlebar.widget.titlewidget(c),
              font = "Iosevka Term " .. beautiful.corner_radius*3/4,
              align = "right",
            },
            layout = wibox.layout.fixed.horizontal
          }
        }
      },
      layout = wibox.layout.fixed.horizontal
    }
    awful.titlebar(c, { position = "left", size = beautiful.corner_radius } ) : setup {
      title_layout,
      bg = "#000000",
      widget = wibox.container.background
    }

    c:connect_signal("unmanage", function()
      -- tidy up!
      if c.cmw.timer then
        c.cmw.timer:stop()
        c.cmw.timer = nil
      end
    end)
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", {raise = true})
-- end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

screen.connect_signal("added", function(s)
  local clients = s.all_clients
  naughty.notify{text=table.concat(clients, "; ")}
end)
-- }}}

awful.spawn.with_shell("~/.config/awesome/autorun.sh")
