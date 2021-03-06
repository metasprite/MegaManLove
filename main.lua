require("requires")

globals = {}

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  OSSystem = love.system.getOS()
  view.init(256, 224, 2)
  useConsole = false
  framerate = 1/60
  showEntityCount = false
  showFPS = false
  touchControls = OSSystem == "Android" or OSSystem == "iOS"
  deadZone = 0.8
  
  if touchControls then
    control.keyboardControls.up = {"up", "touch"}
    control.keyboardControls.down = {"down", "touch"}
    control.keyboardControls.left = {"left", "touch"}
    control.keyboardControls.right = {"right", "touch"}
    control.keyboardControls.jump = {"jump", "touch"}
    control.keyboardControls.shoot = {"shoot", "touch"}
    control.keyboardControls.start = {"start", "touch"}
    control.keyboardControls.select = {"select", "touch"}
    control.keyboardControls.prev = {"prev", "touch"}
    control.keyboardControls.next = {"next", "touch"}
    control.keyboardControls.dash = {"dash", "touch"}
  else
    control.keyboardControls.up = {"up", "keyboard"}
    control.keyboardControls.down = {"down", "keyboard"}
    control.keyboardControls.left = {"left", "keyboard"}
    control.keyboardControls.right = {"right", "keyboard"}
    control.keyboardControls.jump = {"z", "keyboard"}
    control.keyboardControls.shoot = {"x", "keyboard"}
    control.keyboardControls.start = {"return", "keyboard"}
    control.keyboardControls.select = {"rshift", "keyboard"}
    control.keyboardControls.prev = {"a", "keyboard"}
    control.keyboardControls.next = {"s", "keyboard"}
    control.keyboardControls.dash = {"c", "keyboard"}
  end
  
  if useConsole then console.init() end
  
  base64SaveFiles = false
  consoleFont = love.graphics.getFont() -- needs to be preserved
  mmFont = love.graphics.newImageFont("assets/misc/mm.png", "$abcdefghijklmnopqrstuvwxyz"
        .. "1234567890!?<>;/ :,-.+()%'")
  cscreen.init(view.w*view.scale, view.h*view.scale, true)
  resized = false
  
  control.init()
  if touchControls then
    touchInput.add("left", "left-down", 16, -140, 64, 64)
    touchInput.add("right", "left-down", 16+64, -140, 64, 64)
    touchInput.add("down", "left-down", 16+32, -140+64, 64, 64)
    touchInput.add("up", "left-down", 16+32, -140-64, 64, 64)
    touchInput.add("jump", "right-down", -80, -140, 64, 64)
    touchInput.add("dash", "right-down", -80-64, -140+32, 64, 64)
    touchInput.add("shoot", "right-down", -80, -140+64, 64, 64)
    touchInput.add("start", "right-up", -40, 16, 40, 40)
    touchInput.add("select", "right-up", -80, 16, 40, 40)
    touchInput.add("escape", "left-up", 0, 16, 40, 40)
    touchInput.add("prev", "right-up", -40, 60, 40, 40)
    touchInput.add("next", "right-up", -80, 60, 40, 40)
  end
  
  globals.checkpoint = "start"
  globals.infiniteLives = false
  globals.lives = 3
  globals.lifeSegments = 7
  globals.eTanks = 1
  globals.wTanks = 1
  globals.maxLifeSegments = 7
  globals.maxLives = 10
  globals.maxETanks = 10
  globals.maxWTanks = 10
  globals.restart = true
  
  globals.defeats = {}
  globals.defeats.stickMan = false
  
  globals.resetState = true
  globals.manageStageResources = true
  if love.joystick then globals.gamepadCheck = {} end
  
  megautils.load()
  states.set("states/menus/disclaimerstate.lua")
end

function love.resize(w, h)
  cscreen.update(w, h)
  resized = true
end

function love.keypressed(k, s, r)
  -- keypressed event must be hijacked for console to work
	if useConsole and (console.state == 1) then
		if (k == "backspace") then
			console.backspace()
		end
		if (k == "return") then
			console.send()
		end
		if (k == "up" or k == "down") then
			console.cycle(k)
		end
		if (k == "tab" and #console.input > 0 and #console.getCompletion(console.input) > 0) then
			console.complete()
		end
		return
	end
  globals.lastKeyPressed = {k, "keyboard"}
end

function touchInput.touchPressed(b)
  globals.lastKeyPressed = {b, "touch"}
end

function love.gamepadpressed(j, b)
  globals.lastKeyPressed = {b, "gamepad"}
end

function love.gamepadaxis(j, b, v)
  if not globals.gamepadCheck[b]
    and not math.between(v, -deadZone, deadZone) then
    if (b == "leftx" or b == "lefty" or b == "rightx" or b == "righty") then
      globals.axisTmp = {}
      if b == "leftx" or b == "rightx" then
        globals.axisTmp["x"] = {b .. ternary(v > 0,  "+", "-"), "axis", v}
      elseif b == "lefty" or b == "righty" then
        globals.axisTmp["y"] = {b .. ternary(v > 0,  "+", "-"), "axis", v}
      end
    else
      globals.lastKeyPressed =  {b .. ternary(v > 0,  "+", "-"), "axis"}
    end
    globals.gamepadCheck[b] = true
  elseif globals.gamepadCheck[b] == true then
    globals.gamepadCheck[b] = 10
  end
end

function love.textinput(k)
  if useConsole then console.doInput(k) end
end

function love.update(dt)
  control.update()
  if useConsole then console.update(dt) end
  states.update(dt)
  states.switched = false
  control.flush()
  if love.joystick then
    if globals.axisTmp ~= nil then
      if globals.axisTmp["x"] ~= nil and (globals.axisTmp["y"] == nil or
        math.abs(globals.axisTmp["x"][3]) > math.abs(globals.axisTmp["y"][3])) then
        globals.lastKeyPressed = {globals.axisTmp["x"][1], globals.axisTmp["x"][2]}
      elseif globals.axisTmp["y"] ~= nil then
        globals.lastKeyPressed = {globals.axisTmp["y"][1], globals.axisTmp["y"][2]}
      end
      globals.axisTmp = nil
    end
    for k, v in pairs(globals.gamepadCheck) do
      if type(globals.gamepadCheck[k]) == "number" then
        globals.gamepadCheck[k] = globals.gamepadCheck[k] - 1
        if globals.gamepadCheck[k] < 0 then
          globals.gamepadCheck[k] = nil
        end
      end
    end
  end
end

function love.draw()
  love.graphics.push()
  states.draw()
  love.graphics.pop()
  if useConsole then console.draw() end
  if touchControls then
    touchInput.draw()
  end
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
	if love.load then love.load(arg) end
	if love.timer then love.timer.step() end
	local dt = 0
	while true do
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
    local before_update = love.timer.getTime()
		if love.update then love.update(dt) end
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
      love.graphics.present()
		end
		local delta = love.timer.getTime() - before_update
    if delta < framerate then love.timer.sleep(framerate - delta) end
    resized = false
	end
end
