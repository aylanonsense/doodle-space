local Game = require('game/Game')
local controllers = require('input/controllers')

-- -- Constants
-- local CAMERA_SENSITIVITY = 0.5

-- Game variables
local game
-- local enableMouseLook
-- local obj
-- local obj

function love.load()
--   -- Start with mouse look off
--   enableMouseLook = false

  -- Set some graphics values
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setBackgroundColor(0.92, 0.57, 0.69)

  -- Create the game
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  game = Game:new(width, height)

--   -- Move the camera
--   scene.camera:translate(3, 3, 7):rotate(0, math.pi, 0):calculateTransform()

--   -- Add vectors to better show the origin and each axis
--   scene:addArrowInDirection({ 0, 0, 0 }, { 1, 0, 0 }, 10, textures.red)
--   scene:addArrowInDirection({ 0, 0, 0 }, { 0, 1, 0 }, 10, textures.green)
--   scene:addArrowInDirection({ 0, 0, 0 }, { 0, 0, 1 }, 10, textures.blue)

--   -- Create an object to play around with
--   obj = scene:addEntity(TestSubject:new())
--   obj:translate(3, 1, 5)

--   -- Play with the object
--   -- obj:setAxis({ 0.7, -1, 0.9 }, { 0, 0, -1 })
--   obj:rotate(0, math.pi / 4, 0)
--   -- obj:setRotationRelative(0, 0, 0) --math.pi / 4, 0)
--   -- print('absolute rotation:', obj:getRotation())
--   -- print('relative rotation:', obj:getRotationRelative())
--   obj:setAxis((2 * math.random() - 1) * math.pi, (2 * math.random() - 1) * math.pi, (2 * math.random() - 1) * math.pi, (2 * math.random() - 1) * math.pi, (2 * math.random() - 1) * math.pi, (2 * math.random() - 1) * math.pi)
--   -- obj:setRotationRelative(0, 0, 0)
end

function love.update(dt)
  controllers:update(dt)
  game:update(dt)
--   -- Update the object
--   obj:rotate(dt, 0, 10 * dt)
--   -- obj:transformCamera(scene.camera)

--   -- Read keyboard inputs
--   local forwardMovement = (love.keyboard.isDown('w') and 1 or 0) - (love.keyboard.isDown('s') and 1 or 0)
--   local leftwardMovement = (love.keyboard.isDown('a') and 1 or 0) - (love.keyboard.isDown('d') and 1 or 0)
--   local upwardMovement = (love.keyboard.isDown('space') and 1 or 0) - (love.keyboard.isDown('lctrl') and 1 or 0)
--   local spin = (love.keyboard.isDown('v') and 1 or 0) - (love.keyboard.isDown('c') and 1 or 0)

--   -- Move the camera
--   local speed = love.keyboard.isDown('lshift') and 15 or 3
--   if forwardMovement ~= 0 or leftwardMovement ~= 0 then
--     local angle = scene.camera.rotation.y + math.atan2(leftwardMovement, forwardMovement)
--     scene.camera:translate(speed * math.sin(angle) * dt, 0, speed * math.cos(angle) * dt)
--   end
--   if upwardMovement ~= 0 then
--     scene.camera:translate(0, upwardMovement * speed * dt, 0)
--   end
--   if spin ~= 0 then
--     scene.camera:rotate(0, 0, 3 * spin * CAMERA_SENSITIVITY / 100)
--   end
--   if forwardMovement ~= 0 or leftwardMovement ~= 0 or upwardMovement ~= 0 or spin ~= 0 then
--     scene.camera:calculateTransform()
--   end
end

-- function love.mousemoved(x, y, dx, dy)
--   -- Rotate the camera
--   if enableMouseLook then
--     scene.camera:rotate(0, -dx * CAMERA_SENSITIVITY / 100, 0)
--     scene.camera.rotation.x = math.min(math.max(-math.pi / 2, scene.camera.rotation.x + dy * CAMERA_SENSITIVITY / 100), math.pi / 2)
--     scene.camera:calculateTransform()
--   end
-- end

-- function love.mousepressed()
--   -- Add an arrow to the scene whenever the mouse is clicked
--   if enableMouseLook then
--     local focus = scene.camera
--     local dir = vec3():angleToDir(focus.rotation)
--     scene:addArrowInDirection(focus.position, dir, 5)
--   end
-- end

-- function love.keypressed(btn)
--   -- Toggle whether the camera is controlled by the mouse
--   if btn == 'tab' then
--     enableMouseLook = not enableMouseLook
--     love.mouse.setRelativeMode(enableMouseLook)
--   end
-- end

function love.draw()
  game:draw()
end

-- TODO resize
