local PT = {}

local T = {
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

local Nei = {0,0,0,0,0,0,0,0,0}

-- local function clearNbs(a) for i=1,9 do a[i] = 0 end end -- haven't needed this yet

local function isType(nei, i, type)
  return nei[i] ~= 0 and nei[i].type == type
end

local function seed(p,pixgrid,changer)
  pixgrid:fillNeighbors(p,Nei)
  if isType(Nei, Below, T.Off) then
    p.data.t = 0
    changer:move(p, Nei[Below])
    return
  end
  if isType(Nei, Below, T.Soil) then
    p.data.t = 0
    return
  end
  if not isType(Nei, Below, T.Sand) then
    p.data.t = p.data.t + 1
    if p.data.t > 60 then
      changer:clear(p)
    end
  end
end

local function leaf(p,pixgrid,changer)
  pixgrid:fillNeighbors(p,Nei)
  if isType(Nei, Below, T.Off) or isType(Nei,Below,T.Water) then
    local act = love.math.random(1,4)
    if act == 1 then
      if isType(Nei, Left, T.Off) then
        changer:move(p, Nei[Left])
      end
    elseif act == 2 then
      if isType(Nei, Right, T.Off) then
        changer:move(p, Nei[Right])
        return
      end
    else
      changer:move(p, Nei[Below])
    end
  end
end

local function takeWater(a,b, amt, satRatio)
  amt = amt * math.floor(math.min(0,satRatio - (a.water / b.water)) + 0.99999)
  -- if (b.water <= 0) or (a.water / b.water > satRatio) then return 0 end
  amt = math.min(amt, a.maxWater-a.water)
  b.water = math.max(b.water-amt, 0)
  a.water = a.water + origbw - b.water
  return amt
end

local function sand(p,pixgrid,changer)
  pixgrid:fillNeighbors(p,Nei)
  if isType(Nei, Below, T.Off) or isType(Nei, Below, T.Water) then
    -- changer:overwrite(p,Nei[Below])
    changer:move(p,Nei[Below])
    return
  end
  if isType(Nei,Above,T.Sand) or isType(Nei,Above,T.Water) then
    if (love.math.random(0,1) == 1) and Nei[Left] and Nei[Left].type == T.Off then
      changer:move(p, Nei[Left])
      return
    elseif Nei[Right] ~= 0 and Nei[Right].type == T.Off then
      changer:move(p, Nei[Right])
      return
    end
  end
  local w = p.data.water
  local maxw = p.data.maxWater
  if w < maxw then
    for i=2,6,2 do
      if isType(Nei,i,T.Water) then
        local otherd = Nei[i].data
        otherd.water = otherd.water - 2
        w = w + 2
        p.data.water = w
        if w >= maxw then break end

      elseif isType(Nei,i,T.Sand) then
        local otherd = Nei[i].data
        -- slurp water from sand but only if the saturation ratio is low enough
        if otherd.water > 0 and w / otherd.water < 0.9 then
          otherd.water = otherd.water - 1
          w = w + 1
          p.data.water = w
          if w >= maxw then break end
        end
      end
    end
  end
  local color = C.Sand
  -- When saturated, turn to Soil?
  -- if w >= maxw then
  --   p.type = T.Soil
  --   color = C.Soil
  -- end
  p[3] = math.max(color[1] - w, 130)
  p[4] = math.max(color[2] - w, 130)
  p[5] = math.max(color[3] - w, 0)
end


local function water(p,pixgrid,changer)
  if p.data.water <= 0 then
    changer:clear(p)
    return
  end
  pixgrid:fillNeighbors(p,Nei)
  if Nei[Below] ~= 0 and Nei[Below].type == T.Off then
    changer:move(p,Nei[Below])
    return
  end
  if Nei[Left] ~= 0 and Nei[Left].type == T.Off then
    if Nei[BelowLeft] ~= 0 and Nei[BelowLeft] == T.Off then
      changer:move(p,Nei[BelowLeft])
      return
    end
    changer:move(p,Nei[Left])
    return
  end
  if Nei[Right] ~= 0 and Nei[Right].type == T.Off then
    if Nei[BelowRight] ~= 0 and Nei[BelowRight] == T.Off then
      changer:move(p,Nei[BelowRight])
      return
    end
    changer:move(p,Nei[Right])
    return
  end
end

local function soil(p,pixgrid,changer)
  pixgrid:fillNeighbors(p,Nei)
  if isType(Nei, Below, T.Off) or isType(Nei,Below,T.Water) then
    changer:move(p, Nei[Below])
    return
  end
end


PT.Updaters = {}
PT.Updaters[T.Sand] = sand
PT.Updaters[T.Water] = water
PT.Updaters[T.Leaf] = leaf
PT.Updaters[T.Seed] = seed
PT.Updaters[T.Soil] = soil

return PT
