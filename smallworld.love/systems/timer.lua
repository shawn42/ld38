local Comp = require 'ecs/component'

return function(estore,input,res)
  estore:walkEntities(
    hasComps('timer'),
    function(e)
      for _,timer in pairs(e.timers) do
        if timer.countDown then
          if timer.t > 0 then
            timer.alarm = false
            timer.t = timer.t - input.dt
          else
            timer.alarm =  true
            if timer.loop then
              timer.t = timer.reset
            end
          end
        else -- countDown = false (ie, we're counting up)
          timer.t = timer.t + input.dt
          if timer.reset and timer.reset > 0 then
            if timer.t >= timer.reset then
              timer.alarm = true
              if timer.loop then
                timer.t = 0
              else
                timer.t = timer.reset
              end
            end
          end
        end
      end
    end
  )
end
