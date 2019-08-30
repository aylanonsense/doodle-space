local cpml = require('libs/cpml')
local defineClass = require('utils/defineClass')
local Camera = require('3d/Camera')

local Scene = defineClass({
  width = nil,
  height = nil,
  canvas = nil,
  shader = nil,
  models = nil,
  camera = nil,
  init = function(self, width, height)
    self.width = width
    self.height = height
    self.shader = love.graphics.newShader('../shaders/three-dimensional.shader')
    self.canvas = love.graphics.newCanvas(width, height)
    self.models = {}
    self.camera = Camera:new(width / height)
  end,
  draw = function(self)
    love.graphics.setCanvas({ self.canvas, depth = true })
    love.graphics.setShader(self.shader)
    love.graphics.setColor(1, 1, 1)
    love.graphics.clear(0, 0, 0, 0)

    self.shader:send('camera', self.camera.transform)
    self.shader:send('ambientLightLevel', 0.25)
    self.shader:send('ambientLightDirection', { 0, 1, 1 })

    for i=1, #self.models do
      local model = self.models[i]
      if model ~= nil and model.isVisible then
        self.shader:send('modelMatrix', model.transform)
        self.shader:send('modelMatrixInverse', model.inverseTransform)
        love.graphics.setWireframe(model.isWireframe)
        if model.cullBackFacingPolygons then
          love.graphics.setMeshCullMode('back')
        end
        love.graphics.draw(model.mesh, -self.width/2, -self.height/2)
        love.graphics.setMeshCullMode('none')
        love.graphics.setWireframe(false)
    end
    end

    love.graphics.setShader()
    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.canvas, self.width / 2, self.height / 2, 0, 1,-1, self.width / 2, self.height / 2)
  end,
  addModel = function (self, model)
    table.insert(self.models, model)
    return model
  end,
  removeModel = function (self, model)
    for i = 1, #self.models do
      if self.models[i] == model then
        table.remove(self.models, i)
        break;
      end
    end
  end,
  resize = function (self, width, height)
    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height)
    self.camera:setAspectRatio(width / height)
    self.camera:calculatePerspective()
    self.camera:calculateTransform()
  end
})

return Scene
