S = {}

local CrawlSpeed = 0.5
S.crawl = function(e,estore,input,res)
  if e.vel.dx == 0 then
    e.vel.dx = CrawlSpeed

  elseif e.bumper.bumped then
    e.vel.dx = e.vel.dx * -1
    print("crawl: bumped! dx="..e.vel.dx)
  end
end

return S
