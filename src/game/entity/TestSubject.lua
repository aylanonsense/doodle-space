local defineClass = require('utils/defineClass')
local Entity = require('game/entity/Entity')
local Shape = require('scene/Shape')
local textures = require('scene/textures')

local TestSubject = defineClass(Entity, {
  init = function(self)
    Entity.init(self, self.game.scene:spawnModel(Shape.CubePerson, textures.grey))
  end
})

return TestSubject
