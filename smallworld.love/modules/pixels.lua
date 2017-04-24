local M = {}

local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'

local T = Pixtypes.Type
local Color = Pixtypes.Color

local automateTheCellular, prepoluatePixgrid

M.newWorld = function(opts)
  local world = {
    timectrl = {
      interval = 1,  -- how often (in ticks, not time) to actually perform the update
      tickcounter = 0,
      stepwise = false,
      stepped = false,
    },
    bounds = opts.bounds,
    bgcolor = {0,0,0},
    painter = {
      on = false,
      x = 0,
      y = 0,
      type = T.Sand,
      color = Color.Sand,
      brushSize = 10,
    },
    eraser = {
      on = false,
      x = 0,
      y = 0,
      eraserSize = 10,
    },
  }

  local scale = opts.scale or 1
  world.pixgrid = Pixgrid({
    w=world.bounds.w/scale,
    h=world.bounds.h/scale,
    scale=scale,
  })

  prepoluatePixgrid(world.pixgrid)

  return world
end

M.updateWorld = function(world, action)
  if action.type == "tick" then
    -- Use timectrl to decide if we should update this tick or not:
    local tc = world.timectrl
    local doUpdate = false
    if tc.stepwise then
      -- User must kick the simulation along by hitting a key
      if tc.stepped then
        doUpdate = true
        tc.stepped = false
      end
    else
      -- Rate-controlled:
      tc.tickcounter = tc.tickcounter + 1
      if tc.tickcounter >= tc.interval then -- in ticks, not time
        tc.tickcounter = 0
        doUpdate = true
      end
    end

    if doUpdate then
      local painter = world.painter
      local eraser = world.eraser
      if eraser.on then
          for ey=0,eraser.eraserSize-1 do
            for ex=0,eraser.eraserSize-1 do
              world.pixgrid:clear(eraser.x+ex, eraser.y+ey)
            end
          end
      elseif painter.on then
        for i=1,painter.brushSize do
          local x = painter.x + love.math.random(-painter.brushSize, painter.brushSize)
          local y = painter.y + love.math.random(-painter.brushSize, painter.brushSize)
          local p = world.pixgrid:get(x,y)
          if p and p.type == T.Off then
            world.pixgrid:set(x, y, painter.color[1], painter.color[2], painter.color[3], painter.type)
          end
        end
      end

      automateTheCellular(world.pixgrid)
    end

  elseif action.type == 'mouse' then
    local s = world.pixgrid.scale
    if action.state == 'pressed' then
      if action.button == 1 then
        world.painter.on = true
        world.painter.x = math.floor(action.x/s)
        world.painter.y = math.floor(action.y/s)
      else
        world.eraser.on = true
        world.eraser.x = math.floor(action.x/s)
        world.eraser.y = math.floor(action.y/s)
      end
    elseif action.state == 'released' then
      if action.button == 1 then
        world.painter.on = false
      else
        world.eraser.on = false
      end
    elseif action.state == 'moved' then
      world.painter.x = math.floor(action.x/s)
      world.painter.y = math.floor(action.y/s)
      world.eraser.x = math.floor(action.x/s)
      world.eraser.y = math.floor(action.y/s)
    end

  elseif action.type == 'keyboard' then
    if action.state == 'pressed' then

      -- Stepping
      if action.key == 's' then
        world.timectrl.stepwise = not world.timectrl.stepwise
      elseif action.key == 'space' then
        world.timectrl.stepped = true

      -- Brush selection
      elseif action.key == '1' then
        world.painter.type = T.Sand
        world.painter.color = Color.Sand
      elseif action.key == '2' then
        world.painter.type = T.Leaf
        world.painter.color = Color.Leaf
      elseif action.key == '3' then
        world.painter.type = T.Water
        world.painter.color = Color.Water
      elseif action.key == '4' then
        world.painter.type = T.Stone
        world.painter.color = Color.Stone
      end
    end
  end
  return world, nil
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))
  local s = world.pixgrid.scale
  love.graphics.setPointSize(s)
  love.graphics.scale(s,s)
  love.graphics.points(world.pixgrid.buf)
end


--
-- UPDATE ALL THE PIXELS
--
function automateTheCellular(pixgrid)
  -- local sets = {}
  local clears = {}
  local moves = {}

  for i=1,#pixgrid.buf do
    local p = pixgrid.buf[i]
    if p.type == T.Sand then
      local above = pixgrid:get(p[1],p[2]-1)
      local below = pixgrid:get(p[1],p[2]+1)
      if below and (below.type == T.Off or below.type == T.Water) then
        -- move me down
        table.insert(moves, {p,
          {below[1], below[2], p[3],p[4],p[5], p.type}})

      elseif above and above.type ~= T.Off then
        -- move left or right due to weight from above:
        local left = pixgrid:get(p[1]-1,p[2])
        local right = pixgrid:get(p[1]+1,p[2])
        local goLeft = love.math.random(0,1) == 1
        if goLeft and left and left.type == T.Off then
          table.insert(moves, {p,
          {left[1], left[2], p[3],p[4],p[5], p.type}})
        elseif right and right.type == T.Off then
          table.insert(moves, {p,
          {right[1], right[2], p[3],p[4],p[5], p.type}})
        end
      end

    elseif p.type == T.Leaf then
      local below = pixgrid:get(p[1],p[2]+1)
      if below and below.type == T.Off then
        local act = love.math.random(1,4)
        if act == 1 then
          local left = pixgrid:get(p[1]-1, p[2])
          if left and left.type == T.Off then
            table.insert(moves, {p, {left[1], left[2], p[3],p[4],p[5], p.type}})
          end
        elseif act == 2 then
          local right = pixgrid:get(p[1]+1, p[2])
          if right and right.type == T.Off then
            table.insert(moves, {p, {right[1], right[2], p[3],p[4],p[5], p.type}})
          end
        else
          table.insert(moves, {p,
            {below[1], below[2], p[3],p[4],p[5], p.type}})
        end
      end
    elseif p.type == T.Water then
      local below = pixgrid:get(p[1],p[2]+1)
      if below and below.type == T.Off then
          table.insert(moves, {p,
            {below[1], below[2], p[3],p[4],p[5], p.type}})
      else
        local lowleft = pixgrid:get(p[1]-1,p[2]+1)
        local lowright = pixgrid:get(p[1]+1,p[2]+1)
        local go, flipcoin
        if lowleft and lowleft.type == T.Off then
          if lowright and lowright.type == T.Off then
            flipcoin = true
          else
            go = lowleft
          end
        elseif lowright and lowright.type == T.Off then
          go = lowright
        end
        if flipcoin then
          if math.random(0,1) == 0 then
            go = lowleft
          else
            go = lowright
          end
        end

        if not go then
          local left = pixgrid:get(p[1]-1,p[2])
          local right = pixgrid:get(p[1]+1,p[2])
          if left and left.type == T.Off then
            go = left
          elseif right and right.type == T.Off then
            go = right
          end
        end

        if go then
          table.insert(moves, {p,
            {go[1],go[2], p[3],p[4],p[5],p.type}})
        end
      end
    end

  end

  --
  -- Resolve clears, sets and moves:
  --

  for i=1,#clears do
    pixgrid:clear(clears[i][1], clears[i][2])
  end

  -- for i=1,#sets do
  --   pixgrid:set(unpack(v))
  -- end

  local did = {}
  local w = pixgrid.w
  for i=1,#moves do
    src = moves[i][1]
    dest = moves[i][2]

    idx = 1 + dest[1] + (dest[2]*w)
    if not did[idx] then
      pixgrid:set(unpack(dest))
      pixgrid:clear(src[1],src[2])
      did[idx] = true
    end
  end

end

local function addSandDunes(pixgrid, freq, amp, topEdge)
  local top, y
  local c = Color.Sand
  local bar = topEdge or (pixgrid.h - amp) -- y location in the pixgrid of top edge of the wave
  for x = 0, pixgrid.w-1 do
    top = bar  + math.floor(math.sin(x/freq) * (amp/2))
    for y = top, bar + amp do
      pixgrid:set(x,y, c[1], c[2], c[3], T.Sand)
    end
  end
end

function prepoluatePixgrid(pixgrid)
  addSandDunes(pixgrid, 15, 12)
end

return M
