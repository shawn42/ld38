local Stats = require 'stats'
local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local Color = Pixtypes.Color

local automateTheCellular

local brushStyleFuncs = {
  squareSpray = function(pixgrid,x,y,brush)
    for i=1,brush.rate do
      local x = x + love.math.random(-brush.size, brush.size)
      local y = y + love.math.random(-brush.size, brush.size)
      local p = pixgrid:get(x,y)
      if p and p.type == T.Off then
        pixgrid:set(x, y, brush.color[1], brush.color[2], brush.color[3], brush.type)
      end
    end
  end,

  squareSolid = function(pixgrid,x,y,brush)
    local s = brush.size
    local base = - math.floor(s/2)
    for y2=base, base+s do
      for x2=base, base+s do
        pixgrid:set(x+x2, y+y2, brush.color[1], brush.color[2], brush.color[3], brush.type)
      end
    end
  end,

  eraser = function(pixgrid,x,y,brush)
    local s = brush.size
    local base = - math.floor(s/2)
    for y2=base, base+s do
      for x2=base, base+s do
        pixgrid:clear(x+x2, y+y2)
      end
    end
  end,
}

local function updateWorld(world, action)
  if action.type == "tick" then
    local startTime = love.timer.getTime()
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
      for i=1,world.iterations do
        automateTheCellular(world.pixgrid)
      end
    end
    Stats.trackUpdateTime(love.timer.getTime() - startTime)
    Stats.trackFPS(love.timer.getFPS())

  elseif action.type == 'paint' then
    local paintFunc = brushStyleFuncs[action.brush.style]
    if paintFunc then
      local s = world.pixgrid.scale
      local bounds = world.pixgridBounds
      local pgx = math.floor(action.x / s)
      local pgy = math.floor(action.y / s)
      paintFunc(world.pixgrid, pgx, pgy, action.brush)
    end

  elseif action.type == 'keyboard' then
    if action.state == 'pressed' then

      -- Stepping
      if action.key == 's' then
        world.timectrl.stepwise = not world.timectrl.stepwise
      elseif action.key == 'space' then
        world.timectrl.stepped = true

      end
    end
  end

  return world, nil
end

local changer = Pixgrid.Changer()
function automateTheCellular(pixgrid)
  changer:reset()

  for i=1,#pixgrid.buf do
    local p = pixgrid.buf[i]
    --
    -- SAND
    --
    if p.type == T.Sand then
      local above = pixgrid:get(p[1],p[2]-1)
      local below = pixgrid:get(p[1],p[2]+1)
      if below and (below.type == T.Off or below.type == T.Water) then
        -- move me down
        changer:move(p, below)

      elseif above and above.type ~= T.Off then
        -- move left or right due to weight from above:
        local left = pixgrid:get(p[1]-1,p[2])
        local right = pixgrid:get(p[1]+1,p[2])
        local goLeft = love.math.random(0,1) == 1
        if goLeft and left and left.type == T.Off then
          changer:move(p, left)
        elseif right and right.type == T.Off then
          changer:move(p, right)
        end
      end
    --
    -- LEAF
    --
    elseif p.type == T.Leaf then
      local below = pixgrid:get(p[1],p[2]+1)
      if below and below.type == T.Off then
        local act = love.math.random(1,4)
        if act == 1 then
          local left = pixgrid:get(p[1]-1, p[2])
          if left and left.type == T.Off then
            changer:move(p, left)
          end
        elseif act == 2 then
          local right = pixgrid:get(p[1]+1, p[2])
          if right and right.type == T.Off then
            changer:move(p, right)
          end
        else
          changer:move(p, below)
        end
      end
    --
    -- WATER
    --
    elseif p.type == T.Water then
      local below = pixgrid:get(p[1],p[2]+1)
      if below and below.type == T.Off then
          changer:move(p, below)
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
          changer:move(p, go)
        end
      end
    end
  end

  changer:apply(pixgrid)


end

return updateWorld
