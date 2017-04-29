require 'helpers'

local WIDTH = 800
local HEIGHT = 600
local SCALE = 2
local ITERATIONS = 1

local RootModule = require 'modules/gameui'

-- Reference to the root module state
local world

function love.load()
  love.window.setMode(WIDTH,HEIGHT)
  world = RootModule.newWorld({
    bounds={x=0,y=0,w=WIDTH,h=HEIGHT},
    pixels={
      scale=SCALE,              -- apparent pixel size on screen
      iterations=ITERATIONS,
    },
  })
end

local dtAction = {type="tick", dt=0}
function love.update(dt)
  dtAction.dt = dt
  RootModule.updateWorld(world, dtAction)
end

function love.draw()
  RootModule.drawWorld(world)
end

--
-- INPUT EVENT HANDLERS
--
-- NOTE: I reuse these template actions for "efficiency" however
-- this means RootModule.updateWorld must NOT store references to them. :(
-- TODO: just generate a new action structure each time to avoid potential errors.
local keyboardAction = {type="keyboard", action=nil, key=nil}
function toKeyboardAction(state,key)
  keyboardAction.state=state
  keyboardAction.key=key
  return keyboardAction
end
function love.keypressed(key, _scancode, _isrepeat)
  RootModule.updateWorld(world, toKeyboardAction("pressed",key))
end
function love.keyreleased(key, _scancode, _isrepeat)
  RootModule.updateWorld(world, toKeyboardAction("released",key))
end

local mouseAction = {type="mouse", state=nil, x=0, y=0, dx=0,dy=0,button=0, isTouch=0}
function toMouseAction(s,x,y,b,it,dx,dy)
  mouseAction.state=s
  mouseAction.x=x
  mouseAction.y=y
  mouseAction.button=b
  mouseAction.isTouch=it
  mouseAction.dx=dx
  mouseAction.dy=dy
  return mouseAction
end

function love.mousepressed(x,y, button, isTouch, dx, dy)
  RootModule.updateWorld(world, toMouseAction("pressed",x,y,button,isTouch))
end

function love.mousereleased(x,y, button, isTouch)
  RootModule.updateWorld(world, toMouseAction("released",x,y,button,isTouch))
end

function love.mousemoved(x,y, dx,dy, isTouch)
  RootModule.updateWorld(world, toMouseAction("moved",x,y,nil,isTouch,dx,dy))
end

local touchAction = {type="touch", state=nil, id='', x=0, y=0, dx=0, dy=0}
function toTouchAction(s,id,x,y,dx,dy)
  touchAction.state= s
  touchAction.id = id
  touchAction.x=x
  touchAction.y=y
  touchAction.dx=dx
  touchAction.dy=dy
  return touchAction
end

function love.touchpressed(id, x,y, dx,dy, pressure)
  RootModule.updateWorld(world, toTouchAction("pressed",id,x,y,dx,dy))
end
function love.touchmoved(id, x,y, dx,dy, pressure)
  RootModule.updateWorld(world, toTouchAction("moved",id,x,y,dx,dy))
end
function love.touchreleased(id, x,y, dx,dy, pressure)
  RootModule.updateWorld(world, toTouchAction("released",id,x,y,dx,dy))
end

local joystickAction = {type="joystick", id='TODO', controlType='', control='', value=0}
function toJoystickAction(controlType, control, value)
  joystickAction.id = 'TODO'
  joystickAction.controlType=controlType
  joystickAction.control=control
  joystickAction.value=(value or 0)
  return joystickAction
end

function love.joystickaxis( joystick, axis, value )
  RootModule.updateWorld(world, toJoystickAction("axis", axis, value))
end

function love.joystickpressed( joystick, button )
  RootModule.updateWorld(world, toJoystickAction("button",button,1))
end

function love.joystickreleased( joystick, button )
  RootModule.updateWorld(world, toJoystickAction("button", button,0))
end
