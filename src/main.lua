local cpml = require('libs/cpml')
local Scene = require('3d/Scene')
local Model = require('3d/Model')
local Shape = require('3d/Shape')
local vec3 = require('3d/vec3')
local textures = require('3d/textures')
local Arrow = require('game/entity/Arrow')

-- Constants
local CAMERA_SENSITIVITY = 0.5

-- Game variables
local scene
local enableMouseLook
local obj
local arrow

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
  -- local texture = love.graphics.newImage('../img/texture.png')
  -- obj = scene:addModel(Model:new(Shape.Arrow:new(1), texture.black))
  -- obj:translate(3, 5, 0):rotate(0, 0, 0):resize(4, 4, 2)
  -- obj:setUpVector({ 2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1 }, { 2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1 })
  -- obj:calculateTransform()
  -- scene:addArrowInDirection(obj.position, obj.unitX, 5, textures.red)
  -- scene:addArrowInDirection(obj.position, obj.unitY, 5, textures.green)
  -- scene:addArrowInDirection(obj.position, obj.unitZ, 5, textures.blue)

  -- Add vectors to better show the origin and each axis
  scene:addArrowInDirection({ 0, 0, 0 }, { 1, 0, 0 }, 10, textures.red)
  scene:addArrowInDirection({ 0, 0, 0 }, { 0, 1, 0 }, 10, textures.green)
  scene:addArrowInDirection({ 0, 0, 0 }, { 0, 0, 1 }, 10, textures.blue)

  arrow = scene:addEntity(Arrow:new())
  arrow:translate(3, 5, 0)
  -- arrow:resize(3, 3, 1)-- :setDirection(1, 0, 1)
  -- arrow:setAxis({ 2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1 }, { 2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1 })
  arrow:setAxis({ 0.9, 0.2, -0.3 }, { 0, 1, 0 })
  arrow:setRotationRelative({ 0, 0, 0 })

  local relative123 = vec3(2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1)
  print('RELATIVE', relative123)
  local absolute123 = arrow:convertToAbsolute(vec3(), relative123)
  print('ABSOLUTE', absolute123)
  local relativeAgain123 = arrow:convertToRelative(vec3(), absolute123)
  print('RELATIVE AGAIN', relativeAgain123)
  local err = vec3():subtract(relative123, relativeAgain123)
  print('ERROR', err)
  -- arrow:setRotationRelative({ math.pi / 2, 0, 0 })
  -- arrow:setRotationRelative({ -math.pi / 4, math.pi / 4, 0 })

  -- arrow:setRotation(0, 0, math.pi / 8)
  -- arrow:rotate(0, math.pi / 2, 0)
  -- local r = arrow:getRotationRelative()
  -- print(r)
  -- arrow:setAxis({ 2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1 }, { 2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1 })
  -- arrow:setRotationRelative(r)
  -- print(arrow:getRotation())
  -- print(arrow:getRotationRelative())
  -- print(arrow:getPosition())
  -- print(arrow:getPositionRelative())
  -- print(arrow:convertToAbsolute(vec3(), 0, 1, 1))

  -- local v = vec3.clone(obj.unitX)
  -- print(v)
  -- v:dirToAngle(v)
  -- v:angleToDir(v)
  -- print(v)v = vec3.clone(obj.unitY)
  -- print(v)
  -- v:dirToAngle(v)
  -- v:angleToDir(v)
  -- print(v)v = vec3.clone(obj.unitZ)
  -- print(v)
  -- v:dirToAngle(v)
  -- v:angleToDir(v)
  -- print(v)
end

function love.update(dt)
  arrow:rotateRelative({ 0, dt, 0 })
  -- arrow:translateRelative({ -dt, dt, dt })
  -- arrow:rotate({ 0, 0, 0 })
  -- obj:setUpVector({ 0.0, 1, n }):calculateTransform()
  -- obj:rotate({ dt, 0, 0 }):calculateTransform()
  -- obj:translateRelative({ 0, 0, dt }):calculateTransform()
  -- scene:addArrowInDirection(obj.position, obj.unitX, 5)
  -- scene:addArrowInDirection(obj.position, obj.unitY, 5)
  -- scene:addArrowInDirection(obj.position, obj.unitZ, 5)
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
    -- scene:addArrowInDirection(obj.position, obj.unitX, 5, textures.red)
    -- scene:addArrowInDirection(obj.position, obj.unitY, 5, textures.green)
    -- scene:addArrowInDirection(obj.position, obj.unitZ, 5, textures.blue)
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
