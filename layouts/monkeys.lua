-- Grab environment.
local awful     = require("awful")
local beautiful = require("beautiful")
local tonumber  = tonumber
local math      = math


function num_or_zero(v)
  v = tonumber(v)
  if v == nil then
    return 0
  else
    return v
  end
end


function arrange(p)

    -- A useless gap (like the dwm patch) can be defined with
    -- beautiful.useless_gap_width .
    local gap = num_or_zero(beautiful.useless_gap)
    local bw = num_or_zero(beautiful.border_width)

    -- Screen.
    local wa = p.workarea
    local cls = p.clients
    local n = #cls
    if n < 1 then
      return;
    end

    -- Width of main column?
    local t = awful.tag.selected(p.screen)
    local mwfact = awful.tag.getmwfact(t)

    local fov = 0.5
    local parts_per = 1/fov
    local total_parts = n + 1
    local poff = wa.width / total_parts
    local pwid = parts_per / total_parts * wa.width;
    -- n :: p :: colw
    -- 1 :: 2 :: wa.width
    -- 2 :: 3 :: 0.66*wa.width
    -- 3 :: 4 :: 0.5*wa.width
    -- 4 :: 5 :: 0.4*wa.width

    local colw = (wa.width) / n
    local colh = wa.height
    for i = 1, #cls do
      local j = #cls + 1 - i
      c = cls[j]
      c:geometry({
        height = colh - 2*bw - 2*gap,
        width = pwid - bw - gap,
        x = wa.x + poff*(i-1),
        y = wa.y + bw + gap,
      })
    end
end

return { name = "monkeys", arrange = arrange }
