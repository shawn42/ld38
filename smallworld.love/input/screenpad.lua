local M = {}

local h = love.graphics.getHeight() / 2
local w = h
M.initialize = function(opts)
  return {
    controllerId = opts.controllerId,
    leftArea = {0,400,200,200},
    leftHome = {100,500},
    leftRadius = h/2,
    leftGesture = {
      on=false,
      id=nil,
      start={},
      last={}
    }
  }
end

local function emitMovementInput(sp, worldInput)
  local g = sp.leftGesture

  local xdist = g.last.x - sp.leftHome[1]
  local xmag = math.clamp(xdist / sp.leftRadius, -1, 1)
  addInputEvent(worldInput, {type='controller', id=sp.controllerId, input="leftx", action=xmag})

  local ydist = g.last.y - sp.leftHome[2]
  local ymag = math.clamp(ydist / sp.leftRadius, -1, 1)
  addInputEvent(worldInput, {type='controller', id=sp.controllerId, input="lefty", action=ymag})
end

local function emitStopMovementInput(sp, worldInput)
  addInputEvent(worldInput, {type='controller', id=sp.controllerId, input="leftx", action=0})
  addInputEvent(worldInput, {type='controller', id=sp.controllerId, input="lefty", action=0})
end

local function start(sp, id, x, y, worldInput)
  local g = sp.leftGesture
  if not g.on then
    if math.pointinrect(x, y, unpack(sp.leftArea)) then
      g.on = true
      g.id = id
      g.start = {x=x, y=y}
      g.last = g.start
      emitMovementInput(sp, worldInput)
    end
  end
end

local function move(sp, id, x, y, worldInput)
  local g = sp.leftGesture
  if g.on and id == g.id then
    g.last = {x=x, y=y}
    emitMovementInput(sp, worldInput)
  end
end

local function done(sp, id, x, y, worldInput)
  local g = sp.leftGesture
  if g.on and id == g.id then
    -- print("DONE leftGesture:\n" .. tdebug(g,'  '))
    g.on = false
    g.id = nil
    g.start = {}
    g.last = {}
    emitStopMovementInput(sp, worldInput)
  end
end

M.handleMouse = function(sp, action, worldInput)
  local id = "m"
  if action.state == 'pressed' then
    start(sp, id, action.x, action.y, worldInput)
  elseif action.state == 'moved' then
    move(sp, id, action.x, action.y, worldInput)
  elseif action.state == 'released' then
    done(sp, id, action.x, action.y, worldInput)
  end
end

M.handleTouch = function(sp, action, worldInput)
  local id = action.id
  if action.state == 'pressed' then
    start(sp, id, action.x, action.y, worldInput)
  elseif action.state == 'moved' then
    move(sp, id, action.x, action.y, worldInput)
  elseif action.state == 'released' then
    done(sp, id, action.x, action.y, worldInput)
  end
end

return M
