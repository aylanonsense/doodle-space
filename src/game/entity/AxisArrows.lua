local defineClass = require('utils/defineClass')
local Entity = require('game/entity/Entity')
local Shape = require('scene/Shape')
local textures = require('scene/textures')

-- Constants
local AXIS_ARROW_SHAPE = Shape.Arrow:new(3)

local AxisArrows = defineClass(Entity, {
  target = nil,
  models = nil,
  init = function(self, target)
    Entity.init(self)
    self.target = target
    self.xAxisArrow = self.game.scene:spawnModel(AXIS_ARROW_SHAPE, textures.red)
    self.yAxisArrow = self.game.scene:spawnModel(AXIS_ARROW_SHAPE, textures.green)
    self.zAxisArrow = self.game.scene:spawnModel(AXIS_ARROW_SHAPE, textures.blue)
  end,
  draw = function(self)
    local pos = self.target:getWorldPosition()
    self.xAxisArrow:setPosition(pos):setDirection(self.target.xAxis):calculateTransform()
    self.yAxisArrow:setPosition(pos):setDirection(self.target.yAxis):calculateTransform()
    self.zAxisArrow:setPosition(pos):setDirection(self.target.zAxis):calculateTransform()
  end
})

return AxisArrows
