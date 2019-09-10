local defineClass = require('utils/defineClass')
local Scene = require('scene/Scene')
local textures = require('scene/textures')
local TestSubject = require('game/entity/TestSubject')
local AxisArrows = require('game/entity/AxisArrows')

local Game = defineClass({
  cameraSensitivity = 0.01,
  scene = nil,
  controller = nil,
  entities = nil,
  editMode = false,
  player = nil,
  init = function(self, controller, width, height)
    self.scene = Scene:new(width, height)
    self.controller = controller
    self.entities = {}

    -- Add vectors to better show the origin and each axis
    self.scene:spawnArrowInDirection({ 0, 0, 0 }, { 1, 0, 0 }, 10, textures.red)
    self.scene:spawnArrowInDirection({ 0, 0, 0 }, { 0, 1, 0 }, 10, textures.green)
    self.scene:spawnArrowInDirection({ 0, 0, 0 }, { 0, 0, 1 }, 10, textures.blue)

    -- Move the camera to a good starting position
    self.scene.camera:translate(3, 2, 3):rotate(0.1 * math.pi, -0.75 * math.pi, 0)

    -- Spawn an entity to play with
    self.player = self:spawnEntity(TestSubject)
    self:spawnEntity(AxisArrows, self.player)
    self.player:rotate(-0.8, 0, 0):setAxis({ 2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1 }, { 2 * math.random() - 1, 2 * math.random() - 1, 2 * math.random() - 1 })
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
    -- Look around while in edit mode
    if self.editMode then
      local x, y = self.controller:getJoystick('look')
      local rot = self.scene.camera:getRotation()
      self.scene.camera:setRotation(
        math.min(math.max(-math.pi / 2, rot.x + y * self.cameraSensitivity), math.pi / 2),
        rot.y - x * self.cameraSensitivity,
        rot.z)
    end
    -- Rotate the entity
    self.player:rotate(0, dt, 0)
    -- Update all of the entities
    for _, entity in ipairs(self.entities) do
      entity:update(dt)
    end
  end,
  draw = function(self)
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
    love.mouse.setRelativeMode(self.editMode)
  end,
  disableEditMode = function(self)
    self.editMode = false
    love.mouse.setRelativeMode(self.editMode)
  end,
  resize = function(self, width, height)
    self.scene:resize(width, height)
  end,
  spawnEntity = function(self, EntityClass, ...)
    local entity = EntityClass:newFromObject({ game = self }, ...)
    table.insert(self.entities, entity)
    return entity
  end
})

return Game
