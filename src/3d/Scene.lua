local cpml = require('libs/cpml')
local defineClass = require('utils/defineClass')
local Camera = require('3d/Camera')
local Shape = require('3d/Shape')
local Model = require('3d/Model')
local vec3 = require('3d/vec3')

local THREE_DIMENSIONAL_SHADER = love.graphics.newShader('../shaders/three-dimensional.shader')

local Scene = defineClass({
  ambientLightLevel = 0.25,
  worldLightLevel = 1.00,
  worldLightDirection = { 0.25, 1, 0.5 },
  width = nil,
  height = nil,
  canvas = nil,
  shader = nil,
  camera = nil,
  models = nil,
  init = function(self, width, height)
    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height)
    self.shader = THREE_DIMENSIONAL_SHADER
    self.camera = Camera:new(width / height)
    self.models = {}
  end,
  draw = function(self)
    -- Clear the canvas
    love.graphics.setCanvas({ self.canvas, depth = true })
    love.graphics.setColor(1, 1, 1)
    love.graphics.clear(0, 0, 0, 0)

    -- Send uniforms to the shader
    love.graphics.setShader(self.shader)
    self.shader:send('camera_transform', self.camera.transform)
    self.shader:send('ambient_light_level', self.ambientLightLevel)
    self.shader:send('world_light_level', self.worldLightLevel)
    self.shader:send('world_light_direction', self.worldLightDirection)

    -- Render each model
    for _, model in ipairs(self.models) do
      self.shader:send('model_transform', model.transform)
      self.shader:send('model_transform_inverse', model.transformInverse)
      model:draw()
    end

    -- Copy the 3D render to the actual canvas
    love.graphics.setShader()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.canvas, 0, 0, 0, 1, -1, 0, self.height) -- why is it upside down?
  end,
  resize = function (self, width, height)
    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height)
    self.camera:setAspectRatio(width / height)
    self.camera:calculatePerspective()
    self.camera:calculateTransform()
  end,
  addModel = function (self, model)
    table.insert(self.models, model)
    return model
  end,
  removeModel = function (self, model)
    for i, model2 in ipairs(self.models) do
      if model2 == model then
        table.remove(self.models, i)
        break;
      end
    end
  end,
  addArrowBetweenPoints = function(self, pt1, pt2)
    local diff = vec3.subtract(vec3(), pt2, pt1)
    -- Create an arrow of the correct length
    local shape = Shape.Arrow:new(diff:length())
    local model = Model:new(shape)
    -- Position it at the start point and point it towards the end point
    model:setPosition(pt1)
    model:setDirection(diff)
    model:calculateTransform()
    -- Add the arrow to the scene
    return self:addModel(model)
  end,
  addArrowInDirection = function(self, pos, dir, length)
    -- Create an arrow of the correct length
    local shape = Shape.Arrow:new(length or 1)
    local model = Model:new(shape)
    -- Position it at the start point and point it in the right direction
    model:setPosition(pos)
    model:setDirection(dir)
    model:calculateTransform()
    -- Add the arrow to the scene
    return self:addModel(model)
  end
})

return Scene
