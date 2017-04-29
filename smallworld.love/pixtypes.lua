local PT = {}

local T = {
  Off = 0,
  Sand = 1,
  Leaf = 2,
  Water = 3,
  Stone = 4,
  Entity = 5,
  Seed = 6,
  Grass = 7,
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
  if isType(Nei, Below, T.Sand) then
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

local function sand(p,pixgrid,changer)
  pixgrid:fillNeighbors(p,Nei)
  if isType(Nei, Below, T.Off) or isType(Nei, Below, T.Water) then
    -- changer:overwrite(p,Nei[Below])
    changer:move(p,Nei[Below])
    return
  end
  if isType(Nei,Above,T.Sand) then
    if (love.math.random(0,1) == 1) and Nei[Left] and Nei[Left].type == T.Off then
      changer:move(p, Nei[Left])
    elseif Nei[Right] ~= 0 and Nei[Right].type == T.Off then
      changer:move(p, Nei[Right])
    end
  end
end


local function water(p,pixgrid,changer)
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


PT.Updaters = {}
PT.Updaters[T.Sand] = sand
PT.Updaters[T.Water] = water
PT.Updaters[T.Leaf] = leaf
PT.Updaters[T.Seed] = seed

return PT
