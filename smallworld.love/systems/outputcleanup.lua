
local outputCleanupSystem = defineUpdateSystem({'output'},function(e,estore,input,res)
  for _,out in pairs(e.outputs) do
    -- print("outputCleanupSystem removing "..tdebug(out))
    estore:removeComp(out)
  end
end)

return outputCleanupSystem
