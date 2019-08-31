local cpml = require('libs/cpml')
local defineClass = require('utils/defineClass')

local Camera = defineClass({
  pos = nil,
  rotation = nil,
  perspective = nil,
  transform = nil,
  fov = 80,
  aspectRatio = 1,
  nearClip = 0.1,
  farClip = 10000,
  init = function(self, aspectRatio)
    self.pos = cpml.vec3(0, 0, 0)
    self.rotation = cpml.vec3(0, 0, 0)
    self.aspectRatio = aspectRatio or self.aspectRatio

    -- Calculate the perspective and transformation matrix
    self:calculatePerspective()
    self:calculateTransform()
  end,
  setPosition = function(self, x, y, z)
    self.pos.x, self.pos.y, self.pos.z = x, y, z
    return self
  end,
  translate = function(self, x, y, z)
    self.pos.x, self.pos.y, self.pos.z = self.pos.x + x, self.pos.y + y, self.pos.z + z
    return self
  end,
  setRotation = function(self, x, y, z)
    self.rotation.x, self.rotation.y, self.rotation.z = x, y, z
    return self
  end,
  rotate = function(self, x, y, z)
    self.rotation.x, self.rotation.y, self.rotation.z = self.rotation.x + x, self.rotation.y + y, self.rotation.z + z
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
    self.transform = cpml.mat4()
    self.transform:rotate(self.transform, self.rotation.y, cpml.vec3.unit_x)
    self.transform:rotate(self.transform, self.rotation.x, cpml.vec3.unit_y)
    self.transform:rotate(self.transform, self.rotation.z, cpml.vec3.unit_z)
    self.transform:translate(self.transform, -self.pos)
    self.transform:transpose(self.transform)
    self.transform:mul(self.perspective, self.transform)
    return self
  end
})

return Camera
