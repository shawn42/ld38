local Stats = {}

local updateTimes = {}
local updateTimesCapacity = 60
local updateTimesChartHeight = 20
local updateTimesChartColor = {255,255,0}

local fpsSeries = {}
local fpsSeriesCapacity = 60
local fpsChartColor = {200,200,200}
local fpsChartHeight = 20

function Stats.trackUpdateTime(elapsed)
  table.insert(updateTimes, elapsed)
  while #updateTimes > updateTimesCapacity do
    table.remove(updateTimes,1)
  end
end

function Stats.drawUpdateTimesChart(x,y)
  love.graphics.setColor(unpack(updateTimesChartColor))
  local base = y + updateTimesChartHeight
  local top,bottom,val
  local num = #updateTimes
  local sum = 0
  for i=1,num do
    val = math.floor(updateTimes[i] * 1000)
    sum = sum + val
    top = base - val
    love.graphics.line(i+x, top, i+x,base)
  end
  local avg = math.round1(sum / num)
  love.graphics.print(tostring(avg).." ms", x+#updateTimes+1,y+base/4)
  love.graphics.setColor(255,0,0)
  local barY = base-16
  love.graphics.line(x, barY, num, barY)
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle("line", x, y, num, updateTimesChartHeight)
end

function Stats.trackFPS(val)
  table.insert(fpsSeries, val)
  while #fpsSeries > fpsSeriesCapacity do
    table.remove(fpsSeries,1)
  end
end

function Stats.drawFPSChart(x,y)
  love.graphics.setColor(unpack(fpsChartColor))
  local base = y + updateTimesChartHeight
  local div = 60/fpsChartHeight
  local top,bottom
  for i=1,#fpsSeries do
    top = base - math.floor(fpsSeries[i] / div)
    love.graphics.line(i+x, top, i+x,base)
  end
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle("line", x, y, #fpsSeries, updateTimesChartHeight)
  love.graphics.print(tostring(fpsSeries[#fpsSeries]).." fps", x+#fpsSeries+1,y+base/4)
end

-- Stats.updateTimes = updateTimes
-- Stats.updateTimesCapacity = updateTimesCapacity

return Stats
