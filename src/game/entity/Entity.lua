local defineClass = require('utils/defineClass')
local cpml = require('libs/cpml')
local vec3 = require('3d/vec3')
local Model = require('3d/Model')
local Shape = require('3d/Shape')
local textures = require('3d/textures')

-- Create an arrow that will be reused for all axes
local axisArrowShape = Shape.Arrow:new(3)
local axisArrowX = Model:new(axisArrowShape, textures.red)
local axisArrowY = Model:new(axisArrowShape, textures.green)
local axisArrowZ = Model:new(axisArrowShape, textures.blue)

local Entity = defineClass({
  position = nil, -- The entity's absolute position
  rotation = nil, -- The entity's rotation relative to its axis
  scale = nil,
  velocity = nil,
  axisX = nil,
  axisY = nil,
  axisZ = nil,
  axisRotation = nil,
  axisTransform = nil,
  axisTransformInverse = nil,
  model = nil,
  shouldDrawAxis = true,
  init = function(self, model)
    self.position = vec3(0, 0, 0)
    self.rotation = vec3(0, 0, 0)
    self.scale = vec3(1, 1, 1)
    self.velocity = vec3(0, 0, 0)
    self.axisX = vec3(1, 0, 0)
    self.axisY = vec3(0, 1, 0)
    self.axisZ = vec3(0, 0, 1)
    self.axisRotation = vec3(0, 0, 0)
    self.axisTransform = cpml.mat4():identity()
    self.axisTransformInverse = cpml.mat4():identity()
    self.model = model
  end,
  draw = function(self, shader)
    if self.model then
      self.model:setPosition(self.position)
      self.model:setArbitraryTransform(self.axisTransform)
      self.model:setRotation(self.rotation)
      self.model:setScale(self.scale)
      self.model:calculateTransform():draw(shader)
    end
  end,
  drawAxis = function(self, shader)
    axisArrowX:setPosition(self.position):setDirection(self.axisX):calculateTransform():draw(shader)
    axisArrowY:setPosition(self.position):setDirection(self.axisY):calculateTransform():draw(shader)
    axisArrowZ:setPosition(self.position):setDirection(self.axisZ):calculateTransform():draw(shader)
  end,
  transformCamera = function(self, camera)
    camera:setPosition(self.position)
    camera:setArbitraryTransform(self.axisTransform)
    camera:setRotation(self.rotation)
    camera:calculateTransform()
  end,
  setAxis = function(self, upX, upY, upZ, forwardX, forwardY, forwardZ)
    local axisX, axisY, axisZ = vec3(), vec3(), vec3() -- TODO remove object instantiation
    -- Expand vector arguments into 6 coordinates
    if not upZ then
      -- 2 vectors (up and forward)
      if upY then
        forwardX, forwardY, forwardZ = upY[1], upY[2], upY[3]
        upX, upY, upZ = upX[1], upX[2], upX[3]
      -- 1 vector (up only)
      else
        upX, upY, upZ = upX[1], upX[2], upX[3]
      end
    end
    upX, upY, upZ = upX or 0, upY or 0, upZ or 0
    if upX == 0 and upY == 0 and upZ == 0 then
      upY = 1
    end
    -- Default the forward vector to the current forward vector
    forwardX, forwardY, forwardZ = forwardX or self.axisZ.x, forwardY or self.axisZ.y, forwardZ or self.axisZ.z
    -- Set the up vector
    axisY:setValues(upX, upY, upZ)
    axisY:normalize(axisY)
    -- Figure out the side vector by taking the cross product of the up and forward(ish) vectors
    axisX:crossValues(axisY, forwardX, forwardY, forwardZ)
    if axisX:isZero() then
      -- The only way the cross product is zero is if the new Y is equal to the old Z. In which case, the X axis can stay the same
      axisX:set(self.axisX)
    else
      axisX:normalize(axisX)
    end
    -- Figure out the exact forward vector by taking the cross product of the up and side vectors
    axisZ:cross(axisX, axisY)
    axisZ:normalize(axisZ) -- is this necessary?
    -- Set the actual axes
    self.axisX:set(axisX)
    self.axisY:set(axisY)
    self.axisZ:set(axisZ)
    -- Create a transformation matrix
    self.axisRotation:dirToAngle(self.axisZ, self.axisY)
    self.axisTransform:identity()
    self.axisTransform:rotate(self.axisTransform, self.axisRotation[2], cpml.vec3.unit_y)
    self.axisTransform:rotate(self.axisTransform, self.axisRotation[1], cpml.vec3.unit_x)
    self.axisTransform:rotate(self.axisTransform, self.axisRotation[3], cpml.vec3.unit_z)
    self.axisTransformInverse:invert(self.axisTransform)
    return self
  end,
  getPosition = function(self, out)
    return self:_convertToRelative(out or vec3(), self.position)
  end,
  getWorldPosition = function(self, out)
    out = out or vec3()
    out[1], out[2], out[3] = self.position.x, self.position.y, self.position.z
    return out
  end,
  setPosition = function(self, x, y, z)
    return self:setWorldPosition(0, 0, 0):translate(x, y, z)
  end,
  setWorldPosition = function(self, x, y, z)
    if y or z then
      self.position:setValues(x, y, z)
    else
      self.position:set(x)
    end
    return self
  end,
  translate = function(self, x, y, z)
    return self:translateWorld(self:_convertToAbsolute(vec3(), x, y, z)) -- TODO remove object instantiation
  end,
  translateWorld = function(self, x, y, z)
    if y or z then
      self.position:addValues(self.position, x, y, z)
    else
      self.position:add(self.position, x)
    end
    return self
  end,
  getRotation = function(self, out)
    out = out or vec3()
    out[1], out[2], out[3] = self.rotation[1], self.rotation[2], self.rotation[3]
    return out
  end,
  setRotation = function(self, x, y, z)
    if y or z then
      self.rotation:setValues(x, y, z)
    else
      self.rotation:set(x)
    end
    self:_wrapRotation(self.rotation, self.rotation)
    return self
  end,
  rotate = function(self, x, y, z)
    if y or z then
      self.rotation:addValues(self.rotation, x, y, z)
    else
      self.rotation:add(self.rotation, x)
    end
    self:_wrapRotation(self.rotation, self.rotation)
    return self
  end,
  getVelocity = function(self, out)
    return self:_convertToRelative(out or vec3(), self.velocity)
  end,
  getWorldVelocity = function(self, out)
    out = out or vec3()
    out[1], out[2], out[3] = self.velocity.x, self.velocity.y, self.velocity.z
    return out
  end,
  setVelocity = function(self, x, y, z)
    return self:setWorldVelocity(0, 0, 0):accelerate(x, y, z)
  end,
  setWorldVelocity = function(self, x, y, z)
    if y or z then
      self.velocity:setValues(x, y, z)
    else
      self.velocity:set(x)
    end
    return self
  end,
  accelerate = function(self, x, y, z)
    return self:accelerateWorld(self:_convertToAbsolute(vec3(), x, y, z)) -- TODO remove object instantiation
  end,
  accelerateWorld = function(self, x, y, z)
    if y or z then
      self.velocity:addValues(self.velocity, x, y, z)
    else
      self.velocity:add(self.velocity, x)
    end
    return self
  end,
  getScale = function(self, out)
    out = out or vec3()
    out[1], out[2], out[3] = self.scale.x, self.scale.y, self.scale.z
    return out
  end,
  setScale = function(self, x, y, z)
    if y or z then
      self.scale:setValues(x, y, z)
    else
      self.scale:set(x)
    end
    return self
  end,
  rescale = function(self, x, y, z)
    if y or z then
      self.scale:multiplyValues(self.scale, x, y, z)
    else
      self.scale:multiply(self.scale, x)
    end
    return self
  end,
  _wrapRotation = function(self, out, x, y, z)
    if not y and not z then
      x, y, z = x[1], x[2], x[3]
    end
    -- Rotation in the x-axis (looking up/down, a.k.a. pitch) stays between -math.pi and math.pi
    x = x % (2 * math.pi)
    if x > math.pi then
      x = x - 2 * math.pi
    end
    -- if x < -math.pi / 2 or x > math.pi / 2 then
    --   -- We've rotated far enough up/down that we're upside-down now
    --   if x > 0 then
    --     x = math.pi - x
    --   else
    --     x = -math.pi - x
    --   end
    --   y = y + math.pi
    --   z = z + math.pi
    -- end
    -- Rotation in the y-axis (looking left/right, a.k.a. yaw) stays between -math.pi and math.pi
    y = y % (2 * math.pi)
    if y > math.pi then
      y = y - 2 * math.pi
    end
    -- Rotation in the z-axis (a.k.a. roll) stays between -math.pi and math.pi
    z = z % (2 * math.pi)
    if z > math.pi then
      z = z - 2 * math.pi
    end
    -- Return the wrapped rotation
    out[1], out[2], out[3] = x, y, z
    return out
  end,
  -- Turns a vector relative to the entity's axis into an absolute one
  _convertToAbsolute = function(self, out, x, y, z)
    local conversion = vec3() -- TODO remove object instantiation
    if y or z then
      conversion:setValues(x, y, z)
    else
      conversion:set(x)
    end
    -- Multiply by the axis transformation
    conversion:applyTransform(conversion, self.axisTransform)
    -- The result is the now-absolute vector
    out[1], out[2], out[3] = conversion[1], conversion[2], conversion[3]
    return out
  end,
  -- Turns a vector into one that's relative to the entity's axis
  _convertToRelative = function(self, out, x, y, z)
    local conversion = vec3() -- TODO remove object instantiation
    -- Create a vec4 from the input
    if y or z then
      conversion:setValues(x, y, z)
    else
      conversion:set(x)
    end
    -- Multiply by the inverse axis transformation
    conversion:applyTransform(conversion, self.axisTransformInverse)
    -- The result is the now-relative vector
    out[1], out[2], out[3] = conversion[1], conversion[2], conversion[3]
    return out
  end
})

return Entity
