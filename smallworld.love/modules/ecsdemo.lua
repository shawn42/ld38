local here = (...):match("(.*/)[^%/]+$")

require 'ecs/ecshelpers'
require 'comps'
local Estore = require 'ecs/estore'
local timerSystem = require 'systems/timer'
local drawSystem = require 'systems/drawstuff'

local setupResources, buildInitEstore -- defined below

local defaultInput = function()
  return { dt=0, events={} }
end

local updateSystems = function(estore,input,res)
  timerSystem(estore,input,res)
end

local M ={}

--
-- INIT
--

M.newWorld = function()
  local res = setupResources()
  local estore = buildInitEstore(res)

  local world = {
    estore = estore,
    input = defaultInput(),
    resources = res,
  }

  return world, nil
end

local Updaters = {}

--
-- UPDATE
--

M.updateWorld = function(world, action)
  local fn = Updaters[action.type]
  if fn then
    return fn(world,action)
  end
  return world, nil
end

Updaters.tick = function(world,action)
  world.input.dt = action.dt
  updateSystems(world.estore, world.input, world.resources)
  world.input = defaultInput() -- reset input after update
  return world, nil
end

--
-- DRAW
--

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(0,0,0)
  drawSystem(world.estore, nil, world.resources)
end

--
-- Initialization helpers
--

function setupResources()
  local res = {}

  -- NOTE: systems/drawstuff label renderer expects resources.fonts to be setup like this:
  res.fonts = {}
  res.fonts["Adventure-50"] = love.graphics.newFont("fonts/Adventure.ttf",50)
  res.fonts["Adventure-100"] = love.graphics.newFont("fonts/Adventure.ttf",100)
  res.fonts["AdventureOutline-50"] = love.graphics.newFont("fonts/Adventure Outline.ttf",50)
  res.fonts["narpassword-medium"] = love.graphics.newFont("fonts/narpassword.ttf",30)

  return res
end

function buildInitEstore(res)
  local estore = Estore:new()
  -- NOTE: See comps.lua for component definitions

  -- Add a label 100px from the top of screen, with a footprint of 800px wide, centered:
  local labelEnt = estore:newEntity({
    {'pos',{x=0, y=100}},
    {'label', {name='helloLabel', text="Hello ECS World", color={150,150,255}, font="Adventure-100", width=800, align='center'}}
  })
  -- NOTE: we don't need the labelEnt just now, but if we wanted to, we could access its
  -- components like this:
  --   labelEnt.pos
  --   labelEnt.label == labelEnt.labels.helloLabel

  return estore
end

return M
