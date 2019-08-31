local cpml = require('libs/cpml')
local Scene = require('3d/Scene')
local Model = require('3d/Model')
local Shape = require('3d/Shape')

-- Constants
local CAMERA_SENSITIVITY = 0.5

-- Game variables
local scene
local enableMouseLook

function love.load()
  -- Start with mouse look off
  enableMouseLook = false

  -- Set some graphics values
  love.graphics.setDepthMode('lequal', true)
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setBackgroundColor(0.92, 0.57, 0.69)

  -- Create the scene
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  scene = Scene:new(width, height)

  -- Move the camera
  scene.camera:translate(5, 1, 5):calculateTransform()

  -- Create an object
  local texture = love.graphics.newImage('../img/texture.png')
  local obj = scene:addModel(Model:new(Shape.Sphere, texture))
  obj:setPosition(5, 3, 1):setRotation(-math.pi / 2 + 0.01, 0.35, 0.0):setScale(1, 3, 1):calculateTransform()

  -- Add vectors to better show the origin and each axis
  scene:addArrowInDirection({ 0, 0, 0 }, { 0, 0, 1 }, 10)
  scene:addArrowInDirection({ 0, 0, 0 }, { 0, 1, 0 }, 10)
  scene:addArrowInDirection({ 0, 0, 0 }, { 1, 0, 0 }, 10)
end

function love.update(dt)
  -- Read keyboard inputs
  local moveX = (love.keyboard.isDown('d') and 1 or 0) - (love.keyboard.isDown('a') and 1 or 0)
  local moveY = (love.keyboard.isDown('s') and 1 or 0) - (love.keyboard.isDown('w') and 1 or 0)
  local moveZ = (love.keyboard.isDown('space') and 1 or 0) - (love.keyboard.isDown('lctrl') and 1 or 0)

  -- Move the camera
  local speed = love.keyboard.isDown('lshift') and 15 or 3
  if moveX ~= 0 or moveY ~= 0 then
    local angle = math.atan2(moveY, moveX)
    scene.camera:translate(math.cos(scene.camera.rotation.x + angle) * speed * dt, 0, math.sin(scene.camera.rotation.x + angle) * speed * dt)
  end
  if moveZ ~= 0 then
    scene.camera:translate(0, moveZ * speed * dt, 0)
  end
  if moveX ~= 0 or moveY ~= 0 or moveZ ~= 0 then
    scene.camera:calculateTransform()
  end
end

function love.mousemoved(x, y, dx, dy)
  -- Rotate the camera
  if enableMouseLook then
    scene.camera:rotate(math.rad(dx * CAMERA_SENSITIVITY), 0, 0)
    scene.camera.rotation.y = math.max(math.min(scene.camera.rotation.y + math.rad(dy * CAMERA_SENSITIVITY), math.pi / 2), -math.pi / 2)
    scene.camera:calculateTransform()
  end
end

function love.keypressed(btn)
  -- Toggle whether the camera is controlled by the mouse
  if btn == 'tab' then
    enableMouseLook = not enableMouseLook
    love.mouse.setRelativeMode(enableMouseLook)
  end
end

function love.draw()
  -- Draw the scene
  scene:draw()
end
