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
<<<<<<< HEAD
  if not isType(Nei, Below, T.Sand) then
    p.data.t = p.data.t + 1
    if p.data.t > 60 then
      changer:clear(p)
    end
=======
  if nei[Below].type == T.Off then
    p.data.t = 0
    changer:move(p, nei[Below])
    return
  end
  -- Age:
  p.data.t = p.data.t + 1
  if p.data.t > 60 then
    changer:clear(p)
>>>>>>> cb929791cab4aa670781634d7df451851c2eecb2
  end
end

local leafMoves = {Left,Right,Below,Below}

local function leaf(p,pixgrid,changer)
  local nei = pixgrid:getNeighbors(p)
  if nei[Below].type == T.Off or nei[Below].type == T.Water then
    local dir = leafMoves[math.random(1,4)]
    if nei[dir].type == T.Off or nei[dir].type == T.Water then
      changer:move(p, nei[dir])
    end
  else
    p.data.life = p.data.life - math.random(0,0.4)
    if p.data.life <= 0 then
      if math.random(1,10) == 1 then
        pixgrid:set(p[1],p[2],
                    C.Seed[1],C.Seed[2],C.Seed[3],
                    T.Seed, {t=0, water=0, maxWater=50})
      else
        pixgrid:set(p[1],p[2],
                    C.Soil[1],C.Soil[2],C.Soil[3],
                    T.Soil, {water=100,maxWater=100})
      end
    end
  end
end

<<<<<<< HEAD
=======

>>>>>>> cb929791cab4aa670781634d7df451851c2eecb2
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
<<<<<<< HEAD
  local w = p.data.water
  if w < p.data.maxWater then
    -- for i=2,6,2 do
    -- local fullFlowNs = {1,2,3,4,6}
    local fullFlowNs = {2,4,6}
    local halfFlowNs = {7,8,9}
    for ii=1,#fullFlowNs do
      i = fullFlowNs[ii]
      if isType(Nei,i,T.Water) then
        local otherd = Nei[i].data
        otherd.water = otherd.water - 2
        w = w + 2
        p.data.water = w
        if w >= p.data.maxWater then break end

      elseif isType(Nei,i,T.Sand) then
        local otherd = Nei[i].data
        if otherd.water > 0 and w / otherd.water < 0.8 then
          otherd.water = otherd.water - 1
          w = w + 1
          p.data.water = w
          if w >= p.data.maxWater then break end
        end
      end
    end
    for ii=1,#halfFlowNs do
      i = halfFlowNs[ii]
      if isType(Nei,i,T.Water) then
        local otherd = Nei[i].data
        otherd.water = otherd.water - 1
        w = w + 1
        p.data.water = w
        if w >= p.data.maxWater then break end

      elseif isType(Nei,i,T.Sand) then
        local otherd = Nei[i].data
        if otherd.water > 0 and w / otherd.water < 0.9 then
          otherd.water = otherd.water - 1
          w = w + 1
          p.data.water = w
          if w >= p.data.maxWater then break end
        end
      end
    end
  end
  p[3] = math.max(C.Sand[1] - w, 130)
  p[4] = math.max(C.Sand[2] - w, 130)
  p[5] = math.max(C.Sand[3] - w, 0)
  -- if isType(Nei,Above,T.Water) then
  --   Nei[Above].data.water = Nei[Above].data.water - 1
  --   p.data.water = p.data.water + 1
  -- end
  -- if isType(Nei,Left,T.Water) then
  --   Nei[Left].data.water = Nei[Left].data.water - 1
  --   p.data.water = p.data.water + 1
  -- end
  -- if isType(Nei,Right,T.Water) then
  --   Nei[Right].data.water = Nei[Right].data.water - 1
  --   p.data.water = p.data.water + 1
  -- end
  -- p[3] = math.max(p[3] - 1, 130)
  -- p[4] = math.max(p[4] - 1, 130)
  -- p[5] = math.max(p[5] - 1, 0)
=======

  absorbWater(p, nei[AboveLeft])
  absorbWater(p, nei[Above])
  absorbWater(p, nei[AboveRight])
  absorbWater(p, nei[Left])
  absorbWater(p, nei[Right])

  p[3] = math.max(C.Sand[1] - p.data.water, 130)
  p[4] = math.max(C.Sand[2] - p.data.water, 130)
  p[5] = math.max(C.Sand[3] - p.data.water, 0)
>>>>>>> cb929791cab4aa670781634d7df451851c2eecb2
end


local function water(p,pixgrid,changer)
  if p.data.water <= 0 then
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

<<<<<<< HEAD
=======
local function soil(p,pixgrid,changer)
  local nei = pixgrid:getNeighbors(p,nei)
  if nei[Below].type == T.Off or nei[Below].type == T.Water then
    changer:move(p, nei[Below])
    return
  end
  if nei[Left].type == T.Off and nei[Above].type ~= T.Off then
    local twoUp = pixgrid:get(p[1],p[2]-2)
    if twoUp.type ~= T.Off then
      changer:move(p, nei[Left])
    end
  elseif nei[Right].type == T.Off and nei[Above].type ~= T.Off then
    local twoUp = pixgrid:get(p[1],p[2]-2)
    if twoUp.type ~= T.Off then
      changer:move(p, nei[Right])
    end
  end
end

local function grass(p,pixgrid,changer)
  local nei = pixgrid:getNeighbors(p,nei)

  if nei[Below].type == T.Off or nei[Below].type == T.Water then
    pixgrid:set(p[1],p[2],
                C.Leaf[1], C.Leaf[2], C.Leaf[3],
                T.Leaf, {life=100})
    return
  end

  absorbLife(p, nei[Below])

  if p.data.life > 30 then -- and nei[Above].type == T.Off then
    pixgrid:set(nei[Above][1], nei[Above][2],
                C.Grass[1], C.Grass[2], C.Grass[3],
                T.Grass, {life=0, maxLife=120})
  end
end
>>>>>>> cb929791cab4aa670781634d7df451851c2eecb2

PT.Updaters = {}
PT.Updaters[T.Sand] = sand
PT.Updaters[T.Water] = water
PT.Updaters[T.Leaf] = leaf
PT.Updaters[T.Seed] = seed
<<<<<<< HEAD
=======
PT.Updaters[T.Soil] = soil
PT.Updaters[T.Grass] = grass
>>>>>>> cb929791cab4aa670781634d7df451851c2eecb2

return PT
