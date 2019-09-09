local defineClass = require('utils/defineClass')
local Vector3 = require('math/Vector3')
local cpml = require('libs/cpml')

local SceneObject = defineClass({
  position = nil,
  rotation = nil,
  _direction = nil,
  scale = nil,
  transform = nil,
  transformInverse = nil,
  init = function(self, shape, texture)
    self.position = Vector3:new()
    self.rotation = Vector3:new()
    self._direction = Vector3:new()
    self.scale = Vector3:new(1, 1, 1)

    -- Calculate the transformation matrix
    self.transform = cpml.mat4()
    self.transformInverse = cpml.mat4()
    self:calculateTransform()
  end,
  getPosition = function(self)
    return self.position
  end,
  setPosition = function(self, x, y, z)
    self.position:set(x, y, z)
    return self
  end,
  translate = function(self, x, y, z)
    self.position:add(x, y, z)
    return self
  end,
  getRotation = function(self)
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
  getDirection = function(self)
    return self._direction:set(self.rotation):toDirection() -- TODO use an object pool
  end,
  setDirection = function(self, x, y, z)
    self.rotation:set(x, y, z):toRotation()
    return self
  end,
  calculateTransform = function(self)
    self.transform:identity()
    -- Apply position
    self.transform:translate(self.transform, self.position)
    -- Apply rotation
    self.transform:rotate(self.transform, self.rotation.y, cpml.vec3.unit_y)
    self.transform:rotate(self.transform, self.rotation.x, cpml.vec3.unit_x)
    self.transform:rotate(self.transform, self.rotation.z, cpml.vec3.unit_z)
    -- Apply scale
    self.transform:scale(self.transform, self.scale)
    -- Finish creating transformation matrices
    self.transform:transpose(self.transform)
    self.transformInverse:invert(self.transform)
    self.transformInverse:transpose(self.transformInverse)
    return self
  end
})

return SceneObject
