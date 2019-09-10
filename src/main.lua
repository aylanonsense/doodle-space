local Game = require('game/Game')
local controllers = require('input/controllers')

-- Game variables
local game

function love.load()
  -- Set some graphics values
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setBackgroundColor(0.92, 0.57, 0.69)

  -- Create a controller
  local controller = controllers:newController()
  controller:map({ controllers.keyboard, controllers.mouse }, {
    buttons = {
      toggleEditMode = { 'tab' },
      createDebugArrow = { 'mouse-btn-1' }
    },
    joysticks = {
      look = 'mouse-move'
    }
  })

  -- Create the game
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  game = Game:new(controller, width, height)
end

function love.update(dt)
  controllers:update(dt)

  -- Update the game
  game:update(dt)

  -- -- Read keyboard inputs
  -- local forwardMovement = (love.keyboard.isDown('w') and 1 or 0) - (love.keyboard.isDown('s') and 1 or 0)
  -- local leftwardMovement = (love.keyboard.isDown('a') and 1 or 0) - (love.keyboard.isDown('d') and 1 or 0)
  -- local upwardMovement = (love.keyboard.isDown('space') and 1 or 0) - (love.keyboard.isDown('lctrl') and 1 or 0)
  -- local spin = (love.keyboard.isDown('v') and 1 or 0) - (love.keyboard.isDown('c') and 1 or 0)

  -- -- Move the camera
  -- local speed = love.keyboard.isDown('lshift') and 15 or 3
  -- if forwardMovement ~= 0 or leftwardMovement ~= 0 then
  --   local angle = game.scene.camera.rotation.y + math.atan2(leftwardMovement, forwardMovement)
  --   game.scene.camera:translate(speed * math.sin(angle) * dt, 0, speed * math.cos(angle) * dt)
  -- end
  -- if upwardMovement ~= 0 then
  --   game.scene.camera:translate(0, upwardMovement * speed * dt, 0)
  -- end
  -- if spin ~= 0 then
  --   game.scene.camera:rotate(0, 0, 3 * spin * CAMERA_SENSITIVITY / 100)
  -- end
  -- if forwardMovement ~= 0 or leftwardMovement ~= 0 or upwardMovement ~= 0 or spin ~= 0 then
  --   game.scene.camera:calculateTransform()
  -- end

  controllers:postUpdate(dt)
end

function love.draw()
  game:draw()
end

function love.resize(width, height)
  game:resize(width, height)
end
