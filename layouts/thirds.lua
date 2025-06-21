-- Grab environment.
local awful     = require("awful")
local beautiful = require("beautiful")
local tonumber  = tonumber
local math      = math


name = "thirds"
local maxn = 3

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
    if n > maxn then
      n = maxn
    end
    -- if n == 1 then
    --   local w = math.max(1920*0.9, wa.width*0.5)
    --   local h = math.max(1080*0.9, wa.height*0.5)
    --   local x = (wa.width - w)*0.5;
    --   local y = (wa.height - h)*0.5;

    --   local c = cls[n]
    --   c:geometry({
    --     height = h,
    --     width = w,
    --     x = wa.x + x,
    --     y = wa.y + y,
    --   })
    --   awful.client.floating.set(c, false)
    --   return;
    -- end

    -- Width of main column?
    local t = awful.tag.selected(p.screen)
    local mwfact = awful.tag.getmwfact(t)

    local colw = (wa.width) / n
    local colh = wa.height
    for i = 1, #cls do
      local j = #cls + 1 - i
      c = cls[j]
      if i <= maxn then 
        c:geometry({
          height = colh - 2*bw - 2*gap,
          width = colw - 2*bw - 2*gap,
          x = wa.x + (i - 1)*colw + bw + gap,
          y = wa.y + bw + gap,
        })
      else
        awful.client.floating.set(c, true)
      end
    end
end

return { name = name, arrange = arrange }
