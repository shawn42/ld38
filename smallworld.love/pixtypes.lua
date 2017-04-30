local PT = {}

local T = {
  NaP = -1,
  Off = 0,
  Sand = 1,
  Leaf = 2,
  Water = 3,
  Stone = 4,
  Entity = 5,
  Seed = 6,
  Soil = 7,
}

local C = {
  Off = {0,0,0},
  Sand = {255,255,150},
  Leaf = {150,255,150},
  Water = {100,100,255},
  Stone = {150,150,150},
  Seed = {255,255,255},
  Grass = {0,255,0},
  Soil = {107,76,42},
}

PT.Type = T
PT.Color = C

local AboveLeft = 1
local Above = 2
local AboveRight = 3
local Left = 4
local Right = 6
local BelowLeft = 7
local Below = 8
local BelowRight = 9


local function seed(p,pixgrid,changer)
  local nei = pixgrid:getNeighbors(p)
  if nei[Below].type == T.Off then
    p.data.t = 0
    changer:move(p, nei[Below])
    return
  end
  if nei[Below].type == T.Soil then
    p.data.t = 0
    return
  end
  -- Age:
  p.data.t = p.data.t + 1
  if p.data.t > 60 then
    changer:clear(p)
  end
end

local function leaf(p,pixgrid,changer)
  local nei = pixgrid:getNeighbors(p)
  if nei[Below].type == T.Off or nei[Below].type == T.Water then
    local act = love.math.random(1,4)
    if act == 1 then
      if nei[Left].type == T.Off then
        changer:move(p, nei[Left])
      end
    elseif act == 2 then
      if nei[Right].type == T.Off then
        changer:move(p, nei[Right])
        return
      end
    else
      changer:move(p, nei[Below])
    end
  end
end

local WaterRates = {
  [T.Sand] = {
    [T.Sand] = { rate = 1, equil = 0.9 },
    [T.Water] = { rate = 2, equil = 100 },  -- theoretically equil could be "inf" but 100 does the trick
  }
}

local function absorbWater(p,other)
  local r = WaterRates[p.type][other.type]
  if r then
    local take = math.min(r.rate, math.max(0, 0.5 * (p.data.water + other.data.water) * r.equil - p.data.water), p.data.maxWater - p.data.water)
    p.data.water = p.data.water + take
    other.data.water = other.data.water - take
  end
end

local function sand(p,pixgrid,changer)
  local nei = pixgrid:getNeighbors(p)
  if nei[Below].type == T.Off or nei[Below].type == T.Water then
    changer:move(p,nei[Below])
    return
  end
  if nei[Above].type == T.Sand or nei[Above].type == T.Water then
    if (love.math.random(0,1) == 1) and nei[Left].type == T.Off then
      changer:move(p, nei[Left])
      return
    elseif nei[Right].type == T.Off then
      changer:move(p, nei[Right])
      return
    end
  end

  absorbWater(p, nei[AboveLeft])
  absorbWater(p, nei[Above])
  absorbWater(p, nei[AboveRight])
  absorbWater(p, nei[Left])
  absorbWater(p, nei[Right])

  p[3] = math.max(C.Sand[1] - p.data.water, 130)
  p[4] = math.max(C.Sand[2] - p.data.water, 130)
  p[5] = math.max(C.Sand[3] - p.data.water, 0)
end


local function water(p,pixgrid,changer)
  if p.data.water < 1 then
    changer:clear(p)
    return
  end
  local nei = pixgrid:getNeighbors(p)
  if nei[Below].type == T.Off then
    changer:move(p,nei[Below])
    return
  end
  if nei[Left].type == T.Off then
    if nei[BelowLeft] == T.Off then
      changer:move(p,nei[BelowLeft])
      return
    end
    changer:move(p,nei[Left])
    return
  end
  if nei[Right].type == T.Off then
    if nei[BelowRight] == T.Off then
      changer:move(p,nei[BelowRight])
      return
    end
    changer:move(p,nei[Right])
    return
  end
end

local function soil(p,pixgrid,changer)
  local nei = pixgrid:getNeighbors(p,nei)
  if nei[Below].type == T.Off or nei[Below].type == T.Water then
    changer:move(p, nei[Below])
  end
end

PT.Updaters = {}
PT.Updaters[T.Sand] = sand
PT.Updaters[T.Water] = water
PT.Updaters[T.Leaf] = leaf
PT.Updaters[T.Seed] = seed
PT.Updaters[T.Soil] = soil

return PT
