local defineClass = require('utils/defineClass')
local Scene = require('scene/Scene')
local textures = require('scene/textures')
local Player = require('game/entity/Player')
local Planet = require('game/entity/Planet')
local AxisArrows = require('game/entity/AxisArrows')

local Game = defineClass({
  lookSensitivity = 0.01,
  scene = nil,
  controller = nil,
  entities = nil,
  groups = nil,
  editMode = true,
  isFreeCamera = false,
  player = nil,
  init = function(self, controller, width, height)
    self.scene = Scene:new(width, height)
    self.controller = controller
    self.entities = {}
    self.groups = {
      planets = {}
    }

    -- Add vectors to better show the origin and each axis
    self.scene:spawnArrowInDirection({ 0, 0, 0 }, { 1, 0, 0 }, 10, textures.red)
    self.scene:spawnArrowInDirection({ 0, 0, 0 }, { 0, 1, 0 }, 10, textures.green)
    self.scene:spawnArrowInDirection({ 0, 0, 0 }, { 0, 0, 1 }, 10, textures.blue)

    -- Move the camera to a good starting position
    self.scene.camera:translate(3, 2, 3):rotate(0.1 * math.pi, -0.75 * math.pi, 0)

    -- Spawn "players"
    for i = 1, 50 do
      local player = self:spawnEntity(Player):translate(math.random(-50, 50), math.random(-50, 50), math.random(-50, 25))
      self:spawnEntity(AxisArrows, player)
    end

    -- Spawn player
    self.player = self:spawnEntity(Player)

    -- Spawn entities
    self:spawnEntity(Planet, 9):translate(-22, 0, 0)
    self:spawnEntity(Planet, 5):translate(-5, 15, -40)
    self:spawnEntity(Planet, 3):translate(15, -5, -20)
  end,
  update = function(self, dt)
    -- Toggle edit mode
    if self.controller:justPressed('toggleEditMode') then
      self:toggleEditMode()
    end
    -- Shoot out debug arrows
    if self.controller:justPressed('createDebugArrow') then
      self.scene:spawnArrowInDirection(self.scene.camera:getPosition(), self.scene.camera:getDirection(), 5)
    end

    -- Get the attributes of the thing we are in control of
    local controlledObj = self.isFreeCamera and self.scene.camera or self.player
    local position = controlledObj:getPosition()
    local rotation = controlledObj:getRotation()

    -- Look around while not in edit mode
    if not self.editMode then
      local x, y = self.controller:getJoystick('look')
      rotation:set(
        math.min(math.max(-math.pi / 2, rotation.x + y * self.lookSensitivity), math.pi / 2),
        rotation.y - x * self.lookSensitivity,
        rotation.z)
    end

    -- Move around
    local moveZ, moveX = self.controller:getJoystick('move')
    local moveY = (self.controller:isDown('moveUp') and 1 or 0) - (self.controller:isDown('moveDown') and 1 or 0)
    local speed = self.controller:isDown('sprint') and 15 or 3
    if moveZ ~= 0 or moveX ~= 0 then
      local angle = rotation.y + math.atan2(moveZ, moveX)
      position:add(-math.sin(angle) * speed * dt, 0, -math.cos(angle) * speed * dt)
    end
    if moveY ~= 0 then
      position:add(0, moveY * speed * dt, 0)
    end

    -- Set the attributes for good measure
    controlledObj:setPosition(position)
    controlledObj:setRotation(rotation)

    -- Update all of the entities
    for _, entity in ipairs(self.entities) do
      entity:update(dt)
    end
  end,
  draw = function(self)
    -- Move the camera to the player
    if not self.isFreeCamera then
      self.player:transformCamera(self.scene.camera)
      local dir = self.player:getWorldRotation():clone():toDirection()
      dir:multiply(-10, -10, -10)
      self.scene.camera:translate(dir)
    end

    -- Update the camera transform
    self.scene.camera:calculateTransform()

    -- Update all of the entity models
    for _, entity in ipairs(self.entities) do
      entity:draw()
    end

    -- Render everything in the 3D scene
    self.scene:draw()
  end,
  toggleEditMode = function(self)
    if self.editMode then
      self:disableEditMode()
    else
      self:enableEditMode()
    end
  end,
  enableEditMode = function(self)
    self.editMode = true
    love.mouse.setRelativeMode(false)
  end,
  disableEditMode = function(self)
    self.editMode = false
    love.mouse.setRelativeMode(true)
  end,
  resize = function(self, width, height)
    self.scene:resize(width, height)
  end,
  spawnEntity = function(self, EntityClass, ...)
    local entity = EntityClass:newFromObject({ game = self }, ...)
    table.insert(self.entities, entity)
    if entity.groups then
      for _, group in ipairs(entity.groups) do
        if not self.groups[group] then
          self.groups[group] = {}
        end
        table.insert(self.groups[group], entity)
      end
    end
    return entity
  end
})

return Game
