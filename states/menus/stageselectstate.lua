local stageselectstate = states.state:extend()

function stageselectstate:begin()
  loader.load("assets/misc/select.png", "mugshots", "texture")
  loader.load("assets/sfx/cursor_move.ogg", "cursor_move", "sound")
  loader.load("assets/sfx/selected.ogg", "selected", "sound")
  megautils.loadStage(self, "assets/maps/stage_select.lua")
  megautils.add(stageSelect())
  megautils.add(fade(false):setAfter(fade.remove))
  view.x, view.y = 0, 0
  mmMusic.playFromFile("assets/sfx/music/select_loop.ogg", "assets/sfx/music/select_intro.ogg")
end

function stageselectstate:update(dt)
  megautils.update(self, dt)
end

function stageselectstate:stop()
  megautils.unload(self)
end

function stageselectstate:draw()
  megautils.draw(self)
end

megautils.cleanFuncs["unload_stageselect"] = function()
  stageSelect = nil
  megautils.cleanFuncs["unload_stageselect"] = nil
end

stageSelect = entity:extend()

function stageSelect:new()
  stageSelect.super.new(self)
  self.transform.y = 8
  self.transform.x = 24
  self:addToGroup("freezable")
  self.quad = love.graphics.newQuad(81, 296, 15, 7, 96, 303)
  self.megaQuad = love.graphics.newQuad(0, 0, 32, 32, 96, 303)
  self.stickQuad = love.graphics.newQuad(32*2, 0, 32, 32, 96, 303)
  self.tex = loader.get("mugshots")
  self.timer = 0
  self.oldX = self.transform.x
  self.oldY = self.transform.y
  self.oldNewX = 0
  self.oldNewY = 0
  self.x = 1
  self.y = 1
  self.transform.x = self.oldX + self.x*80
  self.transform.y = self.oldY + self.y*80
  self.blink = false
  self.stop = false
end

function stageSelect:update(dt)
  local oldx, oldy = self.x, self.y
  
  if control.leftPressed then
    self.x = self.x-1
  elseif control.rightPressed then
    self.x = self.x+1
  elseif control.upPressed then
    self.y = self.y-1
  elseif control.downPressed then
    self.y = self.y+1
  end
  
  self.x = math.wrap(self.x, 0, 2)
  self.y = math.wrap(self.y, 0, 2)
  
  if oldx ~= self.x or oldy ~= self.y then
    mmSfx.play("cursor_move")
    local newx, newy = 0, 0
    if self.x == 0 and self.y == 0 then
      newx = 1
      newy = 0
    elseif self.x == 1 and self.y == 0 then
      newx = 0
      newy = 1
    elseif self.x == 2 and self.y == 0 then
      newx = 1
      newy = 1
    elseif self.x == 0 and self.y == 1 then
      newx = 0
      newy = 2
    elseif self.x == 1 and self.y == 1 then
      newx = 0
      newy = 0
    elseif self.x == 2 and self.y == 1 then
      newx = 1
      newy = 2
    elseif self.x == 0 and self.y == 2 then
      newx = 0
      newy = 3
    elseif self.x == 1 and self.y == 2 then
      newx = 1
      newy = 3
    elseif self.x == 2 and self.y == 2 then
      newx = 0
      newy = 4
    end
    self.megaQuad:setViewport(newx*32, newy*32, 32, 32)
  end
  
  self.timer = math.wrap(self.timer+1, 0, 14)
  self.blink = ternary(self.timer < 7, true, false)
  self.transform.x = self.oldX + self.x*80
  self.transform.y = self.oldY + self.y*72
  
  if (control.startPressed or control.jumpPressed) and not self.stop then
    if self.x == 2 and self.y == 1 then
      mmMusic.stopMusic()
      mmSfx.play("selected")
      megautils.add(fade(false, 4, {255, 255, 255}, function(s)
        if globals.defeats.stickMan then
          megautils.gotoState("states/stages/demostate.lua")
        else
          globals.bossIntroBoss = "stick"
          megautils.gotoState("states/menus/bossintrostate.lua")
        end
        megautils.remove(s, true)
      end))
      self.stop = true
    end
  elseif control.selectPressed and not self.stop then
    self.stop = true
    megautils.gotoState("states/menus/menustate.lua")
    mmMusic.stopMusic()
  end
end

function stageSelect:allDefeated()
  for k, v in pairs(globals.defeats) do
    if not v then
      return false
    end
  end
  return true
end

function stageSelect:draw()
  if not self:allDefeated() then
    love.graphics.draw(self.tex, self.megaQuad, 112, 88)
  end --else
    --Draw Dr. Wily icon here
  --end
  if not globals.defeats.stickMan then
    love.graphics.draw(self.tex, self.stickQuad, 192, 88)
  end
  if self.blink and not self.stop then
    love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y)
    love.graphics.draw(self.tex, self.quad, self.transform.x+32, self.transform.y)
    love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y+40)
    love.graphics.draw(self.tex, self.quad, self.transform.x+32, self.transform.y+40)
  end
end

return stageselectstate