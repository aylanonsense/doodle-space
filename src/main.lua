local Game = require('game/Game')
local controllers = require('input/controllers')
local textures = require('scene/textures')
local TestSubject = require('game/entity/TestSubject')
local cpml = require('libs/cpml')

-- Constants
local CAMERA_SENSITIVITY = 0.5

-- Game variables
local game
local enableMouseLook
local entity

function love.load()
  -- Set some graphics values
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setBackgroundColor(0.92, 0.57, 0.69)

  -- Start with mouse look off
  enableMouseLook = false

  -- Create the game
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  game = Game:new(width, height)

  -- Move the camera
  game.scene.camera:translate(10, 10, 10):rotate(0.1 * math.pi, -0.75 * math.pi, 0):calculateTransform()

  -- Add vectors to better show the origin and each axis
  game.scene:spawnArrowBetweenPoints({ 0, 0, 0 }, { 10, 0, 0 }, textures.red)
  game.scene:spawnArrowBetweenPoints({ 0, 0, 0 }, { 0, 10, 0 }, textures.green)
  game.scene:spawnArrowBetweenPoints({ 0, 0, 0 }, { 0, 0, 10 }, textures.blue)

  -- Spawn an entity to play with
  entity = game:spawnEntity(TestSubject)
  entity:setPosition(3, 0, 3)
end

function love.update(dt)
  controllers:update(dt)

  -- Play with the entity
  -- entity:translate(dt, 0, 0)
  entity:rotate(0, dt, 0)

  -- Update the game
  game:update(dt)

  -- Read keyboard inputs
  local forwardMovement = (love.keyboard.isDown('w') and 1 or 0) - (love.keyboard.isDown('s') and 1 or 0)
  local leftwardMovement = (love.keyboard.isDown('a') and 1 or 0) - (love.keyboard.isDown('d') and 1 or 0)
  local upwardMovement = (love.keyboard.isDown('space') and 1 or 0) - (love.keyboard.isDown('lctrl') and 1 or 0)
  local spin = (love.keyboard.isDown('v') and 1 or 0) - (love.keyboard.isDown('c') and 1 or 0)

  -- Move the camera
  local speed = love.keyboard.isDown('lshift') and 15 or 3
  if forwardMovement ~= 0 or leftwardMovement ~= 0 then
    local angle = game.scene.camera.rotation.y + math.atan2(leftwardMovement, forwardMovement)
    game.scene.camera:translate(speed * math.sin(angle) * dt, 0, speed * math.cos(angle) * dt)
  end
  if upwardMovement ~= 0 then
    game.scene.camera:translate(0, upwardMovement * speed * dt, 0)
  end
  if spin ~= 0 then
    game.scene.camera:rotate(0, 0, 3 * spin * CAMERA_SENSITIVITY / 100)
  end
  if forwardMovement ~= 0 or leftwardMovement ~= 0 or upwardMovement ~= 0 or spin ~= 0 then
    game.scene.camera:calculateTransform()
  end
end

function love.draw()
  game:draw()
end

function love.mousemoved(x, y, dx, dy)
  -- Rotate the camera
  if enableMouseLook then
    game.scene.camera:rotate(0, -dx * CAMERA_SENSITIVITY / 100, 0)
    game.scene.camera.rotation.x = math.min(math.max(-math.pi / 2, game.scene.camera.rotation.x + dy * CAMERA_SENSITIVITY / 100), math.pi / 2)
    game.scene.camera:calculateTransform()
  end
end

function love.mousepressed()
  -- Add an arrow to the scene whenever the mouse is clicked
  if enableMouseLook then
    local focus = game.scene.camera
    game.scene:spawnArrowInDirection(focus:getWorldPosition(), focus:getDirection(), 5) -- TODO getWorldDirection
  end
end

function love.keypressed(btn)
  -- Toggle whether the camera is controlled by the mouse
  if btn == 'tab' then
    enableMouseLook = not enableMouseLook
    love.mouse.setRelativeMode(enableMouseLook)
  end
end
