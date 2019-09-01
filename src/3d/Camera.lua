local cpml = require('libs/cpml')
local defineClass = require('utils/defineClass')
local vec3 = require('3d/vec3')

-- Object pool
local tempVec3 = vec3()

local Camera = defineClass({
  position = nil,
  rotation = nil,
  perspective = nil,
  transform = nil,
  fov = 80,
  aspectRatio = 1,
  nearClip = 0.1,
  farClip = 10000,
  init = function(self, aspectRatio)
    self.position = vec3(0, 0, 0)
    self.rotation = vec3(0, 0, 0)
    self.aspectRatio = aspectRatio or self.aspectRatio

    -- Calculate the perspective and transformation matrix
    self:calculatePerspective()
    self.transform = cpml.mat4()
    self:calculateTransform()
  end,
  setPosition = function(self, x, y, z)
    if y or z then
      self.position:setValues(x, y, z)
    else
      self.position:set(x)
    end
    return self
  end,
  translate = function(self, x, y, z)
    if y or z  then
      self.position:addValues(self.position, x, y, z)
    else
      self.position:add(x)
    end
    return self
  end,
  setRotation = function(self, x, y, z)
    if y or z then
      self.rotation:setValues(x, y, z)
    else
      self.rotation:set(x)
    end
    return self
  end,
  rotate = function(self, x, y, z)
    if y or z then
      self.rotation:addValues(self.rotation, x, y, z)
    else
      self.rotation:add(self.rotation, x)
    end
    return self
  end,
  setDirection = function(self, x, y, z)
    if y or z then
      self.rotation:dirToModelAngle(vec3(x, y, z)) -- Unnecessarily makes an extra object
    else
      self.rotation:dirToModelAngle(x)
    end
    return self
  end,
  setAspectRatio = function(self, aspectRatio)
    self.aspectRatio = aspectRatio
    return self
  end,
  calculatePerspective = function(self)
    self.perspective = cpml.mat4.from_perspective(self.fov, self.aspectRatio, self.nearClip, self.farClip)
    self.perspective:transpose(self.perspective)
    return self
  end,
  calculateTransform = function(self)
    self.transform:identity()
    self.transform:rotate(self.transform, self.rotation[3], cpml.vec3.unit_z)
    self.transform:rotate(self.transform, self.rotation[1], cpml.vec3.unit_x)
    self.transform:rotate(self.transform, math.pi - self.rotation[2], cpml.vec3.unit_y)
    tempVec3:multiplyValues(self.position, -1, -1, -1)
    self.transform:translate(self.transform, tempVec3)
    self.transform:transpose(self.transform)
    self.transform:mul(self.perspective, self.transform)
    return self
  end
})

return Camera
