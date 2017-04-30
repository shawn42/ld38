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
  Grass = 8,
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

local WaterRates = {
  [T.Sand] = {
    [T.Sand] = { rate = 1, equil = 0.9 },
    [T.Water] = { rate = 2, equil = 100 },  -- theoretically equil could be "inf" but 100 does the trick
  },
  [T.Seed] = {
    [T.Soil] = { rate = 0.03, equil = 1 },
    -- [T.Water] = { rate = 0.01, equil = 1 },
  },
}
local LifeRates = {
  [T.Grass] = {
    [T.Grass] = { rate = 0.1, equil = 1 },
  },
}

local function absorbWater(p,other)
  local r = WaterRates[p.type][other.type]
  if r then
    local take = math.min(r.rate, math.max(0, 0.5 * (p.data.water + other.data.water) * r.equil - p.data.water), p.data.maxWater - p.data.water)
    p.data.water = p.data.water + take
    other.data.water = other.data.water - take
  end
end
local function absorbLife(p,other)
  local r = LifeRates[p.type][other.type]
  if r then
    local take = math.min(r.rate, math.max(0, 0.5 * (p.data.life + other.data.life) * r.equil - p.data.life), p.data.maxLife - p.data.life)
    p.data.life = p.data.life + take
    other.data.life = other.data.life - take
  end
end

local function seed(p,pixgrid,changer)
  if p.data.water >= p.data.maxWater then
    pixgrid:set(p[1],p[2],
                C.Grass[1],C.Grass[2],C.Grass[3],
                T.Grass, {life=120,maxLife=120})
    return
  end
  local nei = pixgrid:getNeighbors(p)
  if nei[Below].type == T.Soil then
    p.data.t = 0
    absorbWater(p, nei[Left])
    absorbWater(p, nei[BelowLeft])
    absorbWater(p, nei[Below])
    absorbWater(p, nei[BelowRight])
    absorbWater(p, nei[Right])

    local coff = math.floor(p.data.water * 0.02 * 255)
    p[3] = math.max(C.Seed[1] - coff, 0)
    p[4] = math.max(C.Seed[2] - coff, 175)
    p[5] = math.max(C.Seed[3] - coff, 0)

    return
  end
  if nei[Below].type == T.Off then
    p.data.t = 0
    changer:move(p, nei[Below])
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

local function grass(p,pixgrid,changer)
  local nei = pixgrid:getNeighbors(p,nei)

  if nei[Below].type == T.Off or nei[Below].type == T.Water then
    pixgrid:set(p[1],p[2],
                C.Leaf[1], C.Leaf[2], C.Leaf[3],
                T.Leaf, nil)
    return
  end

  absorbLife(p, nei[Below])

  if p.data.life > 30 and nei[Above].type == T.Off then
    pixgrid:set(nei[Above][1], nei[Above][2],
                C.Grass[1], C.Grass[2], C.Grass[3],
                T.Grass, {life=0, maxLife=120})
  end
end

PT.Updaters = {}
PT.Updaters[T.Sand] = sand
PT.Updaters[T.Water] = water
PT.Updaters[T.Leaf] = leaf
PT.Updaters[T.Seed] = seed
PT.Updaters[T.Soil] = soil
PT.Updaters[T.Grass] = grass

return PT
