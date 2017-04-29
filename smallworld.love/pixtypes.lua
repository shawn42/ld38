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

local function seed(p,pixgrid,changer)
  p.data.t = p.data.t + 1
  local below = pixgrid:get(p[1],p[2]+1)
  if below then
    if below.type == T.Off then
      p.data.t = 0
      changer:move(p, below)
    elseif below.type == T.Sand then
      if p.data.t > 60 then
        changer:clear(p)
      end
    end
  end
end

local function leaf(p,pixgrid,changer)
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
end

local function sand(p,pixgrid,changer)
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
end

local AboveLeft = 1
local Above = 2
local AboveRight = 3
local Left = 4
local Right = 6
local BelowLeft = 7
local Below = 8
local BelowRight = 9

local Nei = {0,0,0,0,0,0,0,0,0}

local function clearNbs(a)
  for i=1,9 do a[i] = 0 end
end

local function water2(p,pixgrid,changer)
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

local function water(p,pixgrid,changer)
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

local function waterWithDir(p,pixgrid,changer)
  if p.data then
    print("Data!")
  else
    print("no data")
  end
  local data = p.data
  local dir = 0
  if data then dir = data.dir end

  local below = pixgrid:get(p[1],p[2]+1)
  if below and below.type == T.Off then
    changer:move(p, below)
  else
    local lowleft = pixgrid:get(p[1]-1,p[2]+1)
    local lowright = pixgrid:get(p[1]+1,p[2]+1)
    local go, flipcoin
    if lowleft and lowleft.type == T.Off then
      if lowright and lowright.type == T.Off then
        if dir == -1 then
          go = lowLeft
        elseif dir == 1 then
          go = lowRight
        else
          flipcoin = true
        end
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
    if go == lowleft then
      p.data.dir = -1
    elseif go == lowright then
      p.data.dir = 1
    end

    if not go then
      local left = pixgrid:get(p[1]-1,p[2])
      local right = pixgrid:get(p[1]+1,p[2])
      if left and left.type == T.Off then
        if right and right.type == T.Off then
          if dir == -1 then
            go = left
          elseif dir == 1 then
            go = right
          else
            flipcoin = true
          end
        else
          go = left
        end
      elseif right and right.type == T.Off then
        go = right
      end
      if flipcoin then
        if math.random(0,1) == 0 then
          go = left
        else
          go = right
        end
      end
      if go == left then
        p.data.dir = -1
      elseif go == right then
        p.data.dir = 1
      end
    end

    if go then
      changer:move(p, go)
    end
  end
end

PT.Updaters = {}
PT.Updaters[T.Sand] = sand
PT.Updaters[T.Water] = water2
PT.Updaters[T.Leaf] = leaf
PT.Updaters[T.Seed] = seed

return PT
