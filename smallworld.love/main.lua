require 'helpers'

-- This is the main in-point for the love2d game.

-- The point of this file is to bind some "Module" to
-- love2d's incoming events

-- The Modules don't contain their own state, they instead create
-- an initial state and accept that state in updateWorld and drawWorld.
--
-- Modules are expected to export 3 functions:
--   world = newWorld()
--   updateWorld(world, action)
--   drawWorld(world)
-- Main knows nothing about the structure of 'world'.
-- Main _does_ share an understanding of any action structure that
-- it may pass into the module.  See default structures for
-- dtAction, keyboardAction etc. Below.
-- These types are part of a contract between this outer main and the root module.
-- Feel free to rewrite that contract.
--
-- NOTE: updateWorld may be called for more reasons than game time ticks.
-- It is normal for modules to internally accumulate input actions in a buffer
-- and execute them only when the "tick" action arrives, and clear those internal buffers.
--
-- The root of the module hierarchy:
-- local RootModule = require 'modules/rpg/uimodule'
-- local RootModule = require 'modules/barebones'
local RootModule = require 'modules/pixels'

-- Reference to the root module state
local world

function love.load()
  -- love.window.setMode(1024,768)
  love.window.setMode(800,600)
  world = RootModule.newWorld({
    bounds={x=0,y=0,w=800,h=600}
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
