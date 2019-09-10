local defineClass = require('utils/defineClass')
local Entity = require('game/entity/Entity')
local Shape = require('scene/Shape')
local textures = require('scene/textures')

local Planet = defineClass(Entity, {
  init = function(self, scale)
    Entity.init(self, self.game.scene:spawnModel(Shape.Sphere, textures.grey))
    self:setScale(scale, scale, scale)
  end
})

return Planet
