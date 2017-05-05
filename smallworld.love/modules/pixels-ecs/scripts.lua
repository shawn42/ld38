S = {}

local CrawlSpeed = 0.5
S.crawl = function(e,estore,input,res)
  if e.bumper.bottom then
    e.vel.dy = 0.0
  else
    e.vel.dy = 0.5
  end

  if e.vel.dx > 0 then
    if e.bumper.right then
      if e.bumper.top then
        e.vel.dx = -CrawlSpeed
      else
        e.vel.dy = -0.5
      end
    end
  elseif e.vel.dx < 0 then
    if e.bumper.left then
      if e.bumper.top then
        e.vel.dx = CrawlSpeed
      else
        e.vel.dy = -0.5
      end
    end
  else
    e.vel.dx = CrawlSpeed
  end
end

return S
