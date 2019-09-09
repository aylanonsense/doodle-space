local defineClass = require('utils/defineClass')
local Scene = require('scene/Scene')
local TestSubject = require('game/entity/TestSubject')

local Game = defineClass({
  scene = nil,
  entities = nil,
  init = function(self, width, height)
    self.scene = Scene:new(width, height)
    self.entities = {}
    -- Create some entities
    self:spawnEntity(TestSubject):setWorldPosition(-10, 0, 0)
    self:spawnEntity(TestSubject):setWorldPosition(10, 0, 0)
    self:spawnEntity(TestSubject):setWorldPosition(0, 0, -10)
    self:spawnEntity(TestSubject):setWorldPosition(0, 0, 10)
    self:spawnEntity(TestSubject):setWorldPosition(0, -10, 0)
    self:spawnEntity(TestSubject):setWorldPosition(0, 10, 0)
  end,
  update = function(self, dt)
    for _, entity in ipairs(self.entities) do
      entity:update(dt)
    end
  end,
  draw = function(self)
    for _, entity in ipairs(self.entities) do
      entity:draw()
    end
    self.scene:draw()
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
