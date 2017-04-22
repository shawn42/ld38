
local DBG=false
local BOUNDS=false

-- This is a prototype "output" system.
--
-- Currently it's a catch-all for drawing all the things.
-- Unfortunately it's not yet extensible without just editing the big case statement
-- below.  The estore:walkEntities call below traverses entities in such
-- a way to enforce ordering of draws amongst peers. (See the 'parent' component type's 'order' property.)
--
-- (NOTE: if you don't want to directly manage relative sibling ordering,
-- siblings are ordered according to order of being added to their parent.)

return function(estore,_input_,res) -- _input_ is just to match the pattern of systems, we don't use it
  local drawBounds = false
  estore:walkEntities(hasComps('tag','debug'), function(e)
    if e.tags.debug then
      if e.debugs.drawBounds then
        drawBounds = e.debugs.drawBounds.value
        return false -- stop searching
      end
    end
  end)

  estore:walkEntities(nil, function(e)
    if not e.pos then return false end

    --
    -- IMG
    --
    if e.img then
      local img = e.img
      local x,y = getPos(e)
      local imgRes = res.images[img.imgId]
      if not imgRes then
        error("No image resource '"..img.imgId.."'")
      end
      love.graphics.setColor(unpack(img.color))
      love.graphics.draw(
        res.images[img.imgId],
        x,y,
        img.r,     -- radians
        img.sx, img.sy,
        img.offx, img.offy)

    --
    -- SPRITES
    --
    elseif e.sprite then
      local sprite = e.sprite
      local x,y = getPos(e)
      local sres = res.sprites[e.sprite.spriteId]
      assert(sres,"no sprite res for "..e.sprite.spriteId)
      local frame = sres.frames[e.sprite.frame]
      assert(frame,"no frame="..tostring(e.sprite.frame).." for sprite="..tostring(e.sprite.spriteId))
      love.graphics.draw(
        sres.image,
        sres.frames[e.sprite.frame],
        x,y,
        sprite.r,
        sprite.sx, sprite.sy,
        sprite.offx, sprite.offy)
      -- love.graphics.draw(spritesheet.image, spritesheet.quads.dude, 400,200, 0, 2,2)

    --
    -- LABEL
    --
    elseif e.label then
      local label = e.label
      if label.font then
        local font = res.fonts[label.font]
        if font then love.graphics.setFont(font) end
      end
      love.graphics.setColor(unpack(label.color))
      local x,y = getPos(e)
      if label.height then
        if label.valign == 'middle' then
          local halfLineH = love.graphics.getFont():getHeight() / 2
          y = y + (label.height/2) - halfLineH
        elseif label.valign == 'bottom' then
          local lineH = love.graphics.getFont():getHeight()
          y = y + label.height - lineH
        end
      end
      if label.width then
        local align = label.align
        if not align then align = 'left' end
        love.graphics.printf(label.text, x, y, label.width,label.align)
      else
        love.graphics.print(label.text, x, y)
      end

    --
    -- CIRCLE
    --
    elseif e.circle and e.pos then
      local circle = e.circle
      local x,y = getPos(e)
      x = x + circle.offx
      y = y + circle.offy
      love.graphics.setColor(unpack(circle.color))
      love.graphics.circle("line", x, y, circle.radius)
      love.graphics.circle("fill", x, y, circle.radius)

    --
    -- RECTANGLE
    --
    elseif e.rect and e.pos then
      if DBG then
        print("DRAWING "..e.eid)
      end
      local x,y = getPos(e)
      local rect = e.rect
      love.graphics.setColor(unpack(rect.color))
      love.graphics.rectangle(rect.style, x-rect.offx, y-rect.offy, rect.w, rect.h)

    --
    -- MAP
    --
    elseif e.map then
      local mapid = e.map.id
      local map = res.maps[mapid]
      if map then
        map():draw()
      else
        error("Drawing: no map registered with id="..mapid)
      end
    end



    if BOUNDS or drawBounds then
      if e.pos then
        local x,y = getPos(e)
        love.graphics.setColor(255,255,255)
        love.graphics.line(x-5,y, x+5,y)
        love.graphics.line(x,y-5, x,y+5)
        if e.bounds then
          local b = e.bounds
          love.graphics.rectangle("line", x-b.offx, y-b.offy, b.w, b.h)
        end
      end
    end

    -- drewItems = drewItems + 1
  end)

  if DBG then DBG=false end
  -- print("drawstuff: visited "..drewItems.." items")
end
