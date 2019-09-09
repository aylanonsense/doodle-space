local defineClass = require('utils/defineClass')
local ObjectPool = require('utils/ObjectPool')
local Model = require('scene/Model')
local Shape = require('scene/Shape')
local textures = require('scene/textures')
local Vector3 = require('math/Vector3')
local cpml = require('libs/cpml')

-- Object pool
local vector3Pool = ObjectPool:new(Vector3)
local matrix4Pool = ObjectPool:new(cpml.mat4, true)

-- Helper method
local function extractVectorValues(x, y, z)
  if x and not z then
    return x.x or x[1] or 0, x.y or x[2] or 0, x.z or x[3] or 0
  else
    return x or 0, y or 0, z or 0
  end
end

local Entity = defineClass({
  position = nil,
  rotation = nil,
  scale = nil,
  velocity = nil,
  xAxis = nil,
  yAxis = nil,
  zAxis = nil,
  axisRotation = nil,
  axisTransform = nil,
  axisTransformInverse = nil,
  model = nil,
  shouldDrawAxis = true,
  init = function(self, model)
    self.position = Vector3:new()
    self.rotation = Vector3:new()
    self.scale = Vector3:new(1, 1, 1)
    self.velocity = Vector3:new()
    self.xAxis = Vector3:new(1, 0, 0)
    self.yAxis = Vector3:new(0, 1, 0)
    self.zAxis = Vector3:new(0, 0, 1)
    self.axisRotation = Vector3:new()
    self.axisTransform = cpml.mat4():identity()
    self.axisTransformInverse = cpml.mat4():identity()
    self.rotationTransform = cpml.mat4():identity()
    self.model = model
  end,
  update = function(self, dt) end,
  draw = function(self)
    if self.model then
      self:transformModel(self.model)
    end
  end,
  transformModel = function(self, model)
    model:setPosition(self:getWorldPosition())
    model:setRotation(self:getWorldRotation())
    model:setScale(self:getScale())
    model:calculateTransform()
  end,
  transformCamera = function(self, camera)
    camera:setPosition(self:getWorldPosition())
    camera:setRotation(self:getWorldRotation())
    camera:calculateTransform()
  end,
  setAxis = function(self, upX, upY, upZ, forwardX, forwardY, forwardZ)
    -- 6 arguments: x, y, z, positiveX, positiveY, positiveZ
    if forwardZ then
      -- do nothing
    -- 4 arguments: either x, y, z, Vector3 ~or~ Vector3, x, y, z
    elseif forwardX then
      if type(upX) == 'number' then
        forwardX, forwardY, forwardZ = extractVectorValues(forwardX)
      else
        forwardX, forwardY, forwardZ = upY, upZ, forwardX
        upX, upY, upZ = extractVectorValues(upX)
      end
    -- 3 arguments: x, y, z
    elseif upZ then
      -- do nothing
    -- 2 arguments: Vector3, Vector3
    elseif upY and not upZ then
      forwardX, forwardY, forwardZ = extractVectorValues(upY)
      upX, upY, upZ = extractVectorValues(upX)
    -- 1 argument: Vector3
    elseif upX then
      upX, upY, upZ = extractVectorValues(upX)
    end
    -- Some default valuess
    upX, upY, upZ = upX or 0, upY or 0, upZ or 0
    if upX == 0 and upY == 0 and upZ == 0 then
      upY = 1
    end
    forwardX, forwardY, forwardZ = forwardX or self.zAxis.x, forwardY or self.zAxis.y, forwardZ or self.zAxis.z
    -- Create some unit vectors
    local xAxis = vector3Pool:withdraw('setAxis-xAxis')
    local yAxis = vector3Pool:withdraw('setAxis-yAxis')
    local zAxis = vector3Pool:withdraw('setAxis-zAxis')
    -- Set the up vector
    yAxis:set(upX, upY, upZ):normalize()
    -- Figure out the side vector by taking the cross product of the up and forward(ish) vectors
    xAxis:set(yAxis):cross(forwardX, forwardY, forwardZ):normalize()
    -- The only way the cross product is zero is if the new Y is equal to the old Z. In which case, the X axis can stay the same
    if xAxis:isZero() then
      xAxis:set(self.xAxis)
    end
    -- Figure out the exact forward vector by taking the cross product of the up and side vectors
    zAxis:set(xAxis):cross(yAxis):normalize() -- is normalizing necessary?
    -- Set the actual axes
    self.xAxis:set(xAxis)
    self.yAxis:set(yAxis)
    self.zAxis:set(zAxis)
    -- Create a transformation matrix
    self.axisRotation:set(self.zAxis):toRotation(self.yAxis)
    self.axisTransform:identity()
    self.axisTransform:rotate(self.axisTransform, self.axisRotation.y, cpml.vec3.unit_y)
    self.axisTransform:rotate(self.axisTransform, self.axisRotation.x, cpml.vec3.unit_x)
    self.axisTransform:rotate(self.axisTransform, self.axisRotation.z, cpml.vec3.unit_z)
    self.axisTransformInverse:invert(self.axisTransform)
    return self
  end,
  getPosition = function(self)
    local relativePosition = vector3Pool:withdraw('getPosition-relativePosition')
    return self:_convertToRelative(relativePosition:set(self.position))
  end,
  setPosition = function(self, x, y, z)
    return self:setWorldPosition(0, 0, 0):translate(x, y, z)
  end,
  translate = function(self, x, y, z)
    local relativeTranslation = vector3Pool:withdraw('translate-relativeTranslation')
    return self:translateWorld(self:_convertToWorld(relativeTranslation:set(x, y, z)))
  end,
  getWorldPosition = function(self)
    return self.position
  end,
  setWorldPosition = function(self, x, y, z)
    self.position:set(x, y, z)
    return self
  end,
  translateWorld = function(self, x, y, z)
    self.position:add(x, y, z)
    return self
  end,
  getRotation = function(self, out)
    return self.rotation
  end,
  setRotation = function(self, x, y, z)
    self:_wrapRotation(self.rotation:set(x, y, z))
    return self
  end,
  rotate = function(self, x, y, z)
    self:_wrapRotation(self.rotation:add(x, y, z))
    return self
  end,
  getWorldRotation = function(self)
    -- Create a rotation matrix from the current rotation
    local rotationTransform = matrix4Pool:withdraw('getWorldRotation-rotationTransform')
    rotationTransform:identity()
    rotationTransform:rotate(rotationTransform, self.rotation.y, cpml.vec3.unit_y)
    rotationTransform:rotate(rotationTransform, self.rotation.x, cpml.vec3.unit_x)
    rotationTransform:rotate(rotationTransform, self.rotation.z, cpml.vec3.unit_z)
    -- Create some unit vectors
    local xAxis = vector3Pool:withdraw('getWorldRotation-xAxis')
    local yAxis = vector3Pool:withdraw('getWorldRotation-yAxis')
    local zAxis = vector3Pool:withdraw('getWorldRotation-zAxis')
    xAxis:set(1, 0, 0)
    yAxis:set(0, 1, 0)
    zAxis:set(0, 0, 1)
    -- Rotate them all by the current rotation
    xAxis:applyTransform(rotationTransform)
    yAxis:applyTransform(rotationTransform)
    zAxis:applyTransform(rotationTransform)
    -- Convert them into world vectors
    self:_convertToWorld(xAxis)
    self:_convertToWorld(yAxis)
    self:_convertToWorld(zAxis)
    -- Turn all that into an angle
    local worldRotation = vector3Pool:withdraw('getWorldRotation-worldRotation')
    worldRotation:set(zAxis):toRotation(yAxis)
    -- Create a vector normal to the rotated XZ plane
    local upOrDown = vector3Pool:withdraw('getWorldRotation-upOrDown')
    upOrDown:set(0, yAxis.y >= 0 and 1 or -1, 0)
    local xzPlaneNormal = vector3Pool:withdraw('getWorldRotation-xzPlaneNormal')
    xzPlaneNormal:set(zAxis):cross(upOrDown):cross(zAxis)
    -- Project the x axis onto the XZ plane
    local xAxisProjection = vector3Pool:withdraw('getWorldRotation-xAxisProjection')
    xAxisProjection:set(xAxis):projectOntoPlane(xzPlaneNormal)
    if yAxis.y < 0 then
      xAxisProjection:multiply(-1, -1, -1)
    end
    -- The angle between the x axis and its XZ projection is the actual roll angle
    worldRotation.z = xAxisProjection:angleTo(xAxis, zAxis)
    return self:_wrapRotation(worldRotation)
  end,
  getVelocity = function(self)
    local relativeVelocity = vector3Pool:withdraw('getVelocity-relativeVelocity')
    return self:_convertToRelative(relativeVelocity:set(self.velocity))
  end,
  setVelocity = function(self, x, y, z)
    return self:setWorldVelocity(0, 0, 0):accelerate(x, y, z)
  end,
  accelerate = function(self, x, y, z)
    local relativeAcceleration = vector3Pool:withdraw('accelerate-relativeAcceleration')
    return self:accelerateWorld(self:_convertToWorld(relativeAcceleration:set(x, y, z)))
  end,
  getWorldVelocity = function(self)
    return self.velocity
  end,
  setWorldVelocity = function(self, x, y, z)
    self.velocity:set(x, y, z)
    return self
  end,
  accelerateWorld = function(self, x, y, z)
    self.velocity:add(x, y, z)
    return self
  end,
  getScale = function(self)
    return self.scale
  end,
  setScale = function(self, x, y, z)
    self.scale:set(x, y, z)
    return self
  end,
  rescale = function(self, x, y, z)
    self.scale:multiply(x, y, z)
    return self
  end,
  _wrapRotation = function(self, rotation)
    rotation.x = rotation.x % (2 * math.pi)
    if rotation.x > math.pi then
      rotation.x = rotation.x - 2 * math.pi
    end
    rotation.y = rotation.y % (2 * math.pi)
    if rotation.y > math.pi then
      rotation.y = rotation.y - 2 * math.pi
    end
    rotation.z = rotation.z % (2 * math.pi)
    if rotation.z > math.pi then
      rotation.z = rotation.z - 2 * math.pi
    end
    return rotation
  end,
  -- Turns a vector relative to the entity's axis into a world one
  _convertToWorld = function(self, vec)
    return vec:applyTransform(self.axisTransform)
  end,
  -- Turns a vector into one that's relative to the entity's axis
  _convertToRelative = function(self, vec)
    return vec:applyTransform(self.axisTransformInverse)
  end
})

return Entity
