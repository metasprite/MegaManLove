local gameoverstate = states.state:extend()

function gameoverstate:begin()
  loader.load("assets/misc/select.png", "select", "texture")
  loader.load("assets/misc/cont.png", "cont", "texture")
  loader.load("assets/sfx/cursor_move.ogg", "cursor_move", "sound")
  megautils.loadStage(self, "assets/maps/cont.lua")
  megautils.add(contPanels())
  self.wait = 0
  megautils.add(fade(false):setAfter(fade.remove))
  view.x, view.y = 0, 0
  mmMusic.playFromFile(nil, "assets/sfx/music/game_over.ogg")
end

function gameoverstate:update(dt)
  megautils.update(self, dt)
end

function gameoverstate:draw()
  megautils.draw(self)
end

megautils.cleanFuncs["unload_gameover"] = function()
  contPanels = nil
  globals.gameOverContinueState = nil
  megautils.cleanFuncs["unload_gameover"] = nil
end

contPanels = entity:extend()

function contPanels:new()
  contPanels.super.new(self)
  self.tex = loader.get("cont")
  self.quadOne = love.graphics.newQuad(0, 0, 176, 48, 176, 104)
  self.quadTwo = love.graphics.newQuad(0, 48, 160, 56, 176, 104)
  self.state = 0
  self.timer = 0
end

function contPanels:update(dt)
  self.timer = math.min(self.timer+1, 199)
  if self.timer == 198 then
    self.state = 1
    mmMusic.playFromFile("assets/sfx/music/menu.ogg")
    megautils.add(contSelect())
  end
end

function contPanels:draw()
  if self.state == 1 then
    love.graphics.draw(self.tex, self.quadTwo, 48, 128)
  end
  love.graphics.draw(self.tex, self.quadOne, 40, 56)
end

contSelect = entity:extend()

function contSelect:new()
  contSelect.super.new(self)
  self.transform.x = 56
  self.transform.y = 144
  self.tex = loader.get("select")
  self.pick = 0
  self.offY = self.transform.y
  self.picked = false
  self.quad = love.graphics.newQuad(81, 288, 5, 8, 96, 303)
end

function contSelect:update(dt)
  local old = self.pick
  if control.upPressed then
    self.pick = math.wrap(self.pick-1, 0, 1)
  elseif control.downPressed then
    self.pick = math.wrap(self.pick+1, 0, 1)
  end
  if old ~= self.pick then
    mmSfx.play("cursor_move")
  end
  if (control.jumpPressed or control.startPressed) and not self.picked then
    if self.pick == 1 then
      self.picked = true
      self.render = false
      mmMusic.stopMusic()
      megautils.gotoState(globals.gameOverContinueState)
    elseif self.pick == 0 then
      self.picked = true
      self.render = false
      globals.stopMusicMenu = true
      megautils.gotoState("states/menus/menustate.lua")
    end
  end
  self.transform.y = self.offY + self.pick*16
end

function contSelect:draw()
  love.graphics.draw(self.tex, self.quad, self.transform.x, self.transform.y)
end

return gameoverstate