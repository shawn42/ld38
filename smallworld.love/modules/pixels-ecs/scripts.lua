S = {}

local CrawlSpeed = 0.5
S.crawl = function(e,estore,input,res)
  local speed = CrawlSpeed
  if e.bumper.bottom then
    -- touched down
    e.vel.dy = 0.0
  else
    -- in the air
    e.vel.dy = 0.5
    if not e.bumper.bumped then
      -- free fall (not climbing)
      speed = 0
    end
  end

  if e.vel.dx > 0 then
    if e.bumper.right then
      if e.bumper.top then
        -- blocked to the upper-right, reverse direction
        e.vel.dx = -speed
      else
        -- "jump"
        e.vel.dy = -0.5
      end
    end
  elseif e.vel.dx < 0 then
    if e.bumper.left then
      if e.bumper.top then
        -- blocked to the upper-left, reverse direction
        e.vel.dx = speed
      else
        -- "jump"
        e.vel.dy = -0.5
      end
    end
  else
    e.vel.dx = speed
  end

end

return S
