local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
require("math")
config = awful.util.getdir("config")

local CMW = { mt = {}, wmt = {} }
CMW.wmt.__index = CMW
CMW.__index = CMW


local function run(command)
	local prog = io.popen(command)
	local result = prog:read('*all')
	prog:close()
	return result
end


function get_children(pid)
  local result = run("pgrep -P " .. pid)
  local children = {}
  table.insert(children, pid)
  for child_pid in string.gmatch(result, "%S+") do
    table.insert(children, child_pid)
    for _, grandchild_pid in pairs(get_children(child_pid)) do
      table.insert(children, grandchild_pid)
    end
  end
	return children
end


function get_stats(pid, cb)
  -- local children = get_children(pid)
  awful.spawn.easy_async(
    'bash ' .. config .. '/rpcpu.sh ' .. pid,
    function(stdout, stderr, reason, exit_code)
      local cpu = nil
      local mem = nil
      for match in string.gmatch(stdout, "%S+") do
        if cpu == nil then
          cpu = match
        else
          mem = match
          break
        end
      end
      cb({ cpu = cpu or -1, mem = mem or -1})
    end)
end


function progressbar(id)
  local pb = {
    min_value    = 0,
    max_value    = 100,
    value        = 0,
    paddings     = 0,
    border_width = 0,
    -- forced_width = 100,
    -- forced_height = beautiful.corner_radius*0.35,
    border_color = "#777777",
    color = "#777777",
    background_color = "#000000",
    id           = id,
    widget       = wibox.widget.progressbar,
  }
  return pb
end


function CMW:new(pid, wid)
  local o = setmetatable({}, CMW)
  o.wid = wid
  o.pid = pid
  o.overview = wibox.widget {
    {
      text = "hi",
      font = "Iosevka Term " .. beautiful.corner_radius*3/4,
      id = "summary_tb",
      widget = wibox.widget.textbox
    },
    layout = wibox.layout.fixed.horizontal,
    set_stats = function(self, stats)
      self:get_children_by_id("summary_tb")[1].text = "P:" .. o.pid .. "/cpu:" .. stats.cpu .. "%/mem:" .. stats.mem .. "%"
      -- self:get_children_by_id("mem_pb")[1].value = tonumber(stats.mem)
    end,
  }

  o.bar = wibox.widget {
    {
      progressbar("cpu_pb"),
      top  = 2,
      left = 10,
      bottom = 2,
      widget = wibox.container.margin,
    },
    layout = wibox.layout.fixed.horizontal,
    set_stats = function(self, stats)
      self:get_children_by_id("cpu_pb")[1].value = tonumber(stats.cpu)
      -- self:get_children_by_id("mem_pb")[1].value = tonumber(stats.mem)
    end,
  }

  o.timer = timer({ timeout = 1 })
  o.timer:connect_signal("timeout", function() o:update() end)
  o.timer:start()
  o:update()

  return o
end


function CMW:update()
  get_stats(self.pid,
    function(stats)
      self.overview.stats = stats
      self.bar.stats = stats
    end
  )
end


return CMW
