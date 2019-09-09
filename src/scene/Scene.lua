local defineClass = require('utils/defineClass')
local Model = require('scene/Model')
local Shape = require('scene/Shape')
local Camera = require('scene/Camera')
local textures = require('scene/textures')
local Vector3 = require('math/Vector3')

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
    self.shader = love.graphics.newShader('../shaders/three-dimensional.shader')
    self.camera = Camera:new(width / height)
    self.models = {}
  end,
  draw = function(self)
    love.graphics.push()

    -- Clear the canvas
    love.graphics.setDepthMode('lequal', true)
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
      model:draw(self.shader)
    end

    -- Copy the 3D render to the actual canvas
    love.graphics.setShader()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.canvas, 0, 0, 0, 1, -1, 0, self.height) -- why is it upside down?

    love.graphics.pop()
  end,
  resize = function(self, width, height)
    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height)
    self.camera:setAspectRatio(width / height)
    self.camera:calculatePerspective()
    self.camera:calculateTransform()
  end,
  spawnModel = function(self, ...)
    return self:addModel(Model:newFromObject({ scene = self }, ...))
  end,
  addModel = function(self, model)
    for i, model2 in ipairs(self.models) do
      if model2 == model then
        return model
      end
    end
    table.insert(self.models, model)
    return model
  end,
  removeModel = function(self, model)
    for i, model2 in ipairs(self.models) do
      if model2 == model then
        table.remove(self.models, i)
        break;
      end
    end
  end,
  spawnArrowBetweenPoints = function(self, pt1, pt2, texture)
    local diff = Vector3:new():set(pt2):subtract(pt1) -- TODO object instantiation
    -- Create an arrow of the correct length
    local shape = Shape.Arrow:new(diff:length())
    local model = self:spawnModel(shape, texture or textures.black)
    -- Position it at the start point and point it towards the end point
    model:setPosition(pt1)
    model:setDirection(diff)
    model:calculateTransform()
    -- Add the arrow to the scene
    return self:addModel(model)
  end,
  spawnArrowInDirection = function(self, pos, dir, length, texture)
    -- Create an arrow of the correct length
    local shape = Shape.Arrow:new(length or 1)
    local model = self:spawnModel(shape, texture or textures.black)
    -- Position it at the start point and point it in the right direction
    model:setPosition(pos)
    model:setDirection(dir)
    model:calculateTransform()
    -- Add the arrow to the scene
    return self:addModel(model)
  end
})

return Scene
