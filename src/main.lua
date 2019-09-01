local cpml = require('libs/cpml')
local Scene = require('3d/Scene')
local Model = require('3d/Model')
local Shape = require('3d/Shape')
local vec3 = require('3d/vec3')

-- Constants
local CAMERA_SENSITIVITY = 0.5

-- Game variables
local scene
local enableMouseLook

function love.load()
  -- Start with mouse look off
  enableMouseLook = false

  -- Set some graphics values
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setBackgroundColor(0.92, 0.57, 0.69)

  -- Create the scene
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  scene = Scene:new(width, height)

  -- Move the camera
  scene.camera:translate(3, 3, 7):rotate(0, math.pi, 0):calculateTransform()

  -- Create an object
  local texture = love.graphics.newImage('../img/texture.png')
  local obj = scene:addModel(Model:new(Shape.Cube, texture))
  obj:translate(1, 1, 1):rotate(0, 0, 0):calculateTransform()

  -- Add vectors to better show the origin and each axis
  scene:addArrowInDirection({ 0, 0, 0 }, { 0, 0, 1 }, 10)
  scene:addArrowInDirection({ 0, 0, 0 }, { 0, 1, 0 }, 10)
  scene:addArrowInDirection({ 0, 0, 0 }, { 1, 0, 0 }, 10)
end

function love.update(dt)
  -- Read keyboard inputs
  local forwardMovement = (love.keyboard.isDown('w') and 1 or 0) - (love.keyboard.isDown('s') and 1 or 0)
  local leftwardMovement = (love.keyboard.isDown('a') and 1 or 0) - (love.keyboard.isDown('d') and 1 or 0)
  local upwardMovement = (love.keyboard.isDown('space') and 1 or 0) - (love.keyboard.isDown('lctrl') and 1 or 0)
  local spin = (love.keyboard.isDown('v') and 1 or 0) - (love.keyboard.isDown('c') and 1 or 0)

  -- Move the camera
  local speed = love.keyboard.isDown('lshift') and 15 or 3
  if forwardMovement ~= 0 or leftwardMovement ~= 0 then
    local angle = scene.camera.rotation.y + math.atan2(leftwardMovement, forwardMovement)
    scene.camera:translate(speed * math.sin(angle) * dt, 0, speed * math.cos(angle) * dt)
  end
  if upwardMovement ~= 0 then
    scene.camera:translate(0, upwardMovement * speed * dt, 0)
  end
  if spin ~= 0 then
    scene.camera:rotate(0, 0, 3 * spin * CAMERA_SENSITIVITY / 100)
  end
  if forwardMovement ~= 0 or leftwardMovement ~= 0 or upwardMovement ~= 0 or spin ~= 0 then
    scene.camera:calculateTransform()
  end
end

function love.mousemoved(x, y, dx, dy)
  -- Rotate the camera
  if enableMouseLook then
    scene.camera:rotate(0, -dx * CAMERA_SENSITIVITY / 100, 0)
    scene.camera.rotation.x = math.min(math.max(-math.pi / 2, scene.camera.rotation.x + dy * CAMERA_SENSITIVITY / 100), math.pi / 2)
    scene.camera:calculateTransform()
  end
end

function love.mousepressed()
  -- Add an arrow to the scene whenever the mouse is clicked
  if enableMouseLook then
    local focus = scene.camera
    local dir = vec3():angleToDir(focus.rotation)
    scene:addArrowInDirection(focus.position, dir, 5)
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
