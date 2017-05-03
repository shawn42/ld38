
-- Script system

return defineUpdateSystem(hasComps('script'), function(e,estore,input,res)
  local s = res.scripts[e.script.script]
  if s then s(e,estpre,input,res) end
end)
