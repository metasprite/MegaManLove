timer = entity:extend()

function timer:new(time, func)
  timer.super.new(self)
  self.time = 0
  self.max = time
  self.func = func
end

function timer:update(dt)
  self.time = math.min(self.time+1, self.max)
  if self.time == self.max then
    self.func(self)
  end
end

function timer.winCutscene(func)
  megautils.add(timer(150, function(s)
    if s.state == nil then
      if globals.mainPlayer ~= nil then
        s.timer = 0
        s.state = 0
        mmMusic.stopMusic()
        globals.mainPlayer.velocity.velx = 0
        globals.mainPlayer.control = false
        globals.mainPlayer.doAnimation = false
        globals.mainPlayer.canSwitchWeapons = false
        if globals.mainPlayer.slide then
          globals.mainPlayer.slide = false
          globals.mainPlayer:regBox()
          globals.mainPlayer.transform.y = math.round(globals.mainPlayer.transform.y)
          while globals.mainPlayer:solid(0, 0) do
            globals.mainPlayer.transform.y = globals.mainPlayer.transform.y - 1
          end
          while not globals.mainPlayer:solid(0, 1) do
            globals.mainPlayer.transform.y = globals.mainPlayer.transform.y + 1
          end
          globals.mainPlayer.curAnim = "idle"
        end
      end
    elseif s.state == 0 then
      globals.mainPlayer.velocity.vely = globals.mainPlayer.velocity.vely + .25
      globals.mainPlayer:phys()
      if globals.mainPlayer:solid(0, 1) then
        globals.mainPlayer.ground = true
        globals.mainPlayer.velocity.vely = 0
        globals.mainPlayer.curAnim = "idle"
      else
        globals.mainPlayer.curAnim = "jump"
      end
      globals.mainPlayer:face(globals.mainPlayer.side)
      s.timer = math.min(s.timer+1, 300)
      if s.timer == 300 then
        s.state = 1
        s.timer = 0
        globals.mainPlayer.rise = true
        globals.mainPlayer.doAnimation = true
      end
    elseif s.state == 1 then
      s.timer = math.min(s.timer+1, 80)
      if s.timer == 80 then
        s.state = -1
        megautils.add(fade(true, nil, nil, func))
      end
    end
  end))
end

function timer.absorbCutscene(func)
  megautils.add(timer(150, function(s)
      if s.state == nil then
        mmMusic.playFromFile(nil, "assets/sfx/music/win.ogg")
        if globals.mainPlayer ~= nil then
          s.state = 0
          s.timer = 0
          s.to = (view.x+view.w/2)-globals.mainPlayer.collisionShape.w/2
          globals.mainPlayer.control = false
          globals.mainPlayer.doAnimation = false
          globals.mainPlayer.canSwitchWeapons = false
          if not globals.mainPlayer:solid(0, 1) then
            globals.mainPlayer.curAnim = "jump"
          end
          globals.mainPlayer:face(globals.mainPlayer.side)
          globals.mainPlayer.animations[globals.mainPlayer.curAnim]:update(1/60)
        end
      elseif s.state == 0 then
        if globals.mainPlayer ~= nil then
          s.state = 1
          globals.mainPlayer.velocity.velx = 0
        if globals.mainPlayer.slide then
          globals.mainPlayer.slide = false
          globals.mainPlayer:regBox()
          globals.mainPlayer.transform.y = math.round(globals.mainPlayer.transform.y)
          while globals.mainPlayer:solid(0, 0) do
            globals.mainPlayer.transform.y = globals.mainPlayer.transform.y - 1
          end
          while not globals.mainPlayer:solid(0, 1) do
            globals.mainPlayer.transform.y = globals.mainPlayer.transform.y + 1
          end
          globals.mainPlayer.curAnim = "idle"
        end
          s.timer = 0
        end
      elseif s.state == 1 then
        s.timer = math.min(s.timer+1, 300)
        if s.timer == 300 then
          if globals.mainPlayer.transform.x > s.to then
            globals.mainPlayer.side = -1
            globals.mainPlayer.transform.x = math.max(globals.mainPlayer.transform.x-1.3, s.to)
          else
            globals.mainPlayer.side = 1
            globals.mainPlayer.transform.x = math.min(globals.mainPlayer.transform.x+1.3, s.to)
          end
          if globals.mainPlayer:solid(0, 1) then
            globals.mainPlayer.ground = true
            globals.mainPlayer.velocity.vely = 0
            globals.mainPlayer.curAnim = "run"
          else
            globals.mainPlayer:grav()
            globals.mainPlayer.curAnim = "jump"
          end
          if globals.mainPlayer.transform.x == s.to then
            s.state = 2
            s.timer = 0
            globals.mainPlayer.curAnim = "jump"
            globals.mainPlayer.velocity.vely = globals.mainPlayer.jumpSpeed
            globals.mainPlayer:face(globals.mainPlayer.side)
            return
          end
        else
          globals.mainPlayer.curAnim = "idle"
        end
        globals.mainPlayer.animations[globals.mainPlayer.curAnim]:update(1/60)
        globals.mainPlayer:grav()
        globals.mainPlayer:phys()
        if globals.mainPlayer:solid(0, 1) then
          globals.mainPlayer.ground = true
          globals.mainPlayer.velocity.vely = 0
        else
          globals.mainPlayer.curAnim = "jump"
        end
        globals.mainPlayer:face(globals.mainPlayer.side)
      elseif s.state == 2 then
        globals.mainPlayer.velocity:slowY(0.25)
        globals.mainPlayer:moveBy(globals.mainPlayer.velocity.velx, globals.mainPlayer.velocity.vely)
        if globals.mainPlayer.velocity.vely == 0 then
          megautils.add(absorb(globals.mainPlayer))
          s.state = 3
          s.timer = 0
        end
      elseif s.state == 3 then
        s.timer = math.min(s.timer+1, 230)
        if s.timer == 230 then
          globals.mainPlayer.rise = true
          globals.mainPlayer.doAnimation = true
          s.timer = 0
          s.state = 4
        end
      elseif s.state == 4 then
        s.timer = math.min(s.timer+1, 80)
        if s.timer == 80 then
          s.state = -1
          megautils.add(fade(true, nil, nil, func))
        end
      end
    end))
end