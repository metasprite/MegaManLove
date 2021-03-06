bossdoor = entity:extend()

addobjects.register("boss_door", function(v)
  local seg = ternary(v.properties["dir"]=="up" or v.properties["dir"]=="down", 
    math.round(v.width/16), math.round(v.height/16))
    megautils.add(bossdoor(v.x, v.y, seg, v.properties["dir"],
    v.properties["doScrollX"], v.properties["doScrollY"]))
end)

bossdoor.animGrid = anim8.newGrid(32, 64, 160, 64)

function bossdoor:new(x, y, seg, dir, scrollx, scrolly, spd)
  bossdoor.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self.tex = loader.get("boss_door")
  self.scrollx = scrollx
  self.scrolly = scrolly
  self.quad = love.graphics.newQuad(0, 0, 32, 16, 32, 16)
  self.timer = 0
  self.segments = seg
  self.maxSegments = seg
  self:addToGroup("boss_door")
  self.spd = spd or 1
  self.state = 0
  self.once = false
  self.player = nil
  self:setDirection(dir)
end

function bossdoor:setDirection(dir)
  self:setRectangleCollision(ternary(dir=="up" or dir=="down", self.maxSegments*16, 32),
    ternary(dir=="up" or dir=="down", 32, self.maxSegments*16))
  self.dir = dir or "right"
end

function bossdoor:update(dt)
  if camera.main == nil or not rectOverlaps(self.transform.x, self.transform.y, self.collisionShape.w,
    self.collisionShape.h, camera.main.scrollx, camera.main.scrolly, camera.main.scrollw, camera.main.scrollh) then return end
  if ((self.transform.x < camera.main.scrollx and self.dir == "left") or
    (self.transform.x+self.collisionShape.w > camera.main.scrollx+camera.main.scrollw and self.dir == "right") or
    (self.transform.y < camera.main.scrolly and self.dir == "up") or
    (self.transform.y+self.collisionShape.h > camera.main.scrolly+camera.main.scrollh and self.dir == "down")) then
    self.once = false
    self:removeFromGroup("solid")
  elseif not self.once then
    self.once = true
    self:addToGroup("solid")
  end
  if self.state == 0 then
    self.timer = 0
    if camera.main ~= nil and not camera.main.transition then
      if globals.mainPlayer ~= nil and globals.mainPlayer.control and self:collision(globals.mainPlayer) then
        self.player = globals.mainPlayer
        self.state = 1
        self.player.control = false
        self.player.doAnimation = false
        megautils.freeze({globals.mainPlayer})
        for k, v in pairs(megautils.groups()["removeOnCutscene"] or {}) do
          megautils.remove(v, true)
        end
      end
    end
  elseif self.state == 1 then
    self.timer = math.min(self.timer+1, 8)
    if self.timer == 8 then
      self.timer = 0
      self.segments = math.max(self.segments-1, 0)
      mmSfx.play("boss_door_sfx")
    end
    if self.segments <= 0 then
      self.state = 2
      self.timer = 0
      self.c = "open"
      self.player.doAnimation = true
      camera.main.transX = ternary(self.dir=="up" or self.dir=="down", 0, 
        ternary(self.dir=="left", camera.main.scrollx-self.player.collisionShape.w-28,
          camera.main.scrollx+camera.main.scrollw+28))
      camera.main.transY = ternary(self.dir=="up" or self.dir=="down",
        ternary(self.dir=="up", camera.main.scrolly-self.player.collisionShape.h-28,
          camera.main.scrolly+camera.main.scrollh+28), 0)
      camera.main.transitiondirection = self.dir
      camera.main.doScrollY = ternary(self.scrolly ~= nil, self.scrolly, camera.main.doScrollY)
      camera.main.doScrollX = ternary(self.scrollx ~= nil, self.scrollx, camera.main.doScrollX)
      camera.main.transition = true
      camera.main.toSection = self:collisionTable(megautils.state().sectionHandler.sections, 
        ternary(self.dir=="left" or self.dir=="right", ternary(self.dir=="left", -16, 16),
          0), ternary(self.dir=="up" or self.dir=="down", ternary(self.dir=="up", -16, 16),
          0))[1]
      camera.main.speed = self.spd
      camera.main.player = self.player
      camera.main.updateSections = false
      camera.main.freeze = false
    end
  elseif self.state == 2 then
    if not camera.main.transition then
      self.player.doAnimation = false
      camera.main.transXSpeed = .35
      camera.main.transYSpeed = .45
      self.state = 3
    end
  elseif self.state == 3 then
    self.timer = math.min(self.timer+1, 8)
    if self.timer == 8 then
      self.timer = 0
      self.segments = math.min(self.segments+1, self.maxSegments)
      mmSfx.play("boss_door_sfx")
    end
    if self.segments >= self.maxSegments then
      self.timer = 0
      self.player.control = true
      self.player.doAnimation = true
      camera.main.freeze = true
      camera.main.updateSections = true
      megautils.state().system.afterUpdate = function()
        camera.main:updateBounds()
        camera.main.toSection = nil
        megautils.unfreeze({globals.mainPlayer})
        megautils.state().system.afterUpdate = nil
      end
      self.state = -1
    end
  end
end

function bossdoor:draw()
  if megautils.outside(self) then return end
  love.graphics.setColor(1, 1, 1, 1)
  for i=1, self.segments do
    if self.dir == "left" or self.dir == "right" then
      love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y + (i*16) - 16)
    else
      love.graphics.draw(self.tex, self.quad, self.transform.x + (i*16), self.transform.y, math.rad(90))
    end
  end
  --self.collisionShape:draw()
end