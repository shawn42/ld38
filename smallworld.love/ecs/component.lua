
local ObjPool = require 'ecs/objpool'

-- Define and access Components.
-- Comp.define("Img", {name:""}) creates a new Component type Img, available via Comp.Img.
-- Img now manages an internal object pool and understands what the default Img component looks like.
-- Copies of the proto object are used to fill the pool
--
-- Comp module
--   .define(typeName, protoObj)
--
-- A defined comp Abc:
--   - is referenced via Comp.Abc
--   - has funcs:
--     .copy()        -- acquires a component instance from pool
--     .copy(o)       -- acquires instance from pool and copies values in from o
--     .cleanCopy()   -- acquires instance from pool, resetting all values according to protoObj
--     .cleanCopy(o)  -- same as cleanCopy, then merging in vals from o
--     .release(o)    -- put o back into the pool

local Comp = {
  types = {}
}
Comp.types = {}

local poolDefaults = {
  initSize=5,
  incSize=5,
  mulSize=1,
}

local function mkComp(typeName, fieldNames, proto, poolOpts)
  if not poolOpts then poolOpts = {} end
  local poolInit = poolOpts.initSize or poolDefaults.initSize
  local poolInc = poolOpts.incSize or poolDefaults.incSize
  local poolMul = poolOpts.mulSize or poolDefaults.mulSize

  local pool = ObjPool:new(proto, poolInit, poolInc, poolMul)
  return {
    _pool = pool,

    type = typeName,

    fields = fieldNames,

    copy = function(o)
      local c = pool:get()
      if o then
        for k,v in pairs(o) do
          c[k] = v
        end
      end
      return c
    end,

    cleanCopy = function(o)
      local c = pool:getClean()
      if o then
        for k,v in pairs(o) do
          c[k] = v
        end
      end
      return c
    end,

    release = function(o)
      pool:put(o)
    end
  }
end

local function define(typeName, fields, poolOpts)
  local fnames = {'cid','eid','type','name'}
  local proto = {}
  for i = 1, (#fields-1), 2 do
    proto[fields[i]] = fields[i+1]
    fnames[#fnames+1] = fields[i]
  end

  proto.type = typeName
  proto.cid = ''
  proto.eid = ''
  proto.name = ''

  local c = mkComp(typeName, fnames, proto,poolOpts)
  Comp.types[typeName] = c
  return c
end

local function getT(comp)
  local ct = Comp.types[comp.type]
  if not ct then
    error("GetT() -- no type descriptor for comp.type == "..comp.type)
  end
  return ct
end

local function compDebugString(comp)
  if not comp then return "[NULL Component]" end
  local t = getT(comp)
  local parts = {}
  for i,f in ipairs(t.fields) do
    parts[#parts+1] = f .. "=" ..tostring(comp[f])
  end
  return "[" .. table.concat(parts, " ") .. "]"
end

local function releaseComp(comp)
  local t = getT(comp)
  t.release(comp)
end

Comp.define = define
Comp.release = releaseComp
Comp.debugString = compDebugString

--
-- BUILT-IN COMPONENTS (these are used internally by Estore)
--
-- 'parent' is used to declare parent-child relationships between entities.
Comp.define("parent", {'parentEid', '', 'order',''})

Comp.define("name", {})


return Comp
