require 'helpers'

local ObjPool = {}

function ObjPool:new(proto,initSize,incSize,mulSize)
  if not initSize then initSize = 5 end
  if not incSize then incSize = 10 end
  if not mulSize then mulSize = 1 end

  local items ={}
  for i = 1,initSize do
    items[#items+1] = tcopy(proto)
  end

  local o = {
    proto=proto,
    initSize=initSize,
    incSize=incSize,
    mulSize=mulSize,
    items=items,
    cap=#items,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function ObjPool:get()
  local items = self.items
  local lasti = #items
  if lasti == 0 then
    self:expand()
    lasti = #items
  end
  local obj = items[lasti]
  items[lasti] = nil
  return obj
end

function ObjPool:getClean()
  local obj = self:get()
  tmerge(obj,self.proto)
  return obj
end

function ObjPool:put(obj)
  self.items[#self.items+1] = obj
end

function ObjPool:expand()
  local newCap = (self.cap * self.mulSize) + self.incSize
  local start = #self.items + 1
  local num = newCap - self.cap
  for i = start, num do
    self.items[i] = tcopy(self.proto)
  end
  self.cap = newCap
end

function ObjPool:debugString()
  return "[ObjPool count=" .. #self.items .. " " .. tflatten(self) .. "]"
end

function ObjPool:debugStringFull()
  local str = "[ObjPool count=" .. #self.items .. " " .. tflatten(self) .. "\n"
  for i,item in ipairs(self.items) do
    str = str .. "  " .. i .. ": " .. tflatten(item) .. "\n"
  end
  return str
end

return ObjPool
