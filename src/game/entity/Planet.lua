local defineClass = require('utils/defineClass')
local Entity = require('game/entity/Entity')
local Shape = require('scene/Shape')
local textures = require('scene/textures')

local Planet = defineClass(Entity, {
  groups = { 'planets' },
  radius = 1,
  mass = 0,
  init = function(self, radius)
    Entity.init(self, self.game.scene:spawnModel(Shape.Sphere, textures.grey))

    -- Set scale and mass
    self.radius = radius or 1
    -- self.mass = math.pi * self.radius * self.radius * self.radius * 4 / 3
    self.mass = 5 + 2 * self.radius
    self:setScale(self.radius, self.radius, self.radius)
  end
})

return Planet
