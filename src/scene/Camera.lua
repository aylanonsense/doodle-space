local defineClass = require('utils/defineClass')
local SceneObject = require('scene/SceneObject')
local ObjectPool = require('utils/ObjectPool')
local Vector3 = require('math/Vector3')
local cpml = require('libs/cpml')

-- Object pools
local vector3Pool = ObjectPool:new(Vector3)

local Camera = defineClass(SceneObject, {
  perspective = nil,
  fov = 80,
  aspectRatio = 1,
  nearClip = 0.1,
  farClip = 10000,
  init = function(self, aspectRatio)
    self.aspectRatio = aspectRatio or self.aspectRatio
    self:calculatePerspective()
    SceneObject.init(self)
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
    self.transform:rotate(self.transform, self.rotation.z, cpml.vec3.unit_z)
    self.transform:rotate(self.transform, self.rotation.x, cpml.vec3.unit_x)
    self.transform:rotate(self.transform, math.pi - self.rotation.y, cpml.vec3.unit_y)
    local positionNegative = vector3Pool:withdraw('calculateTransform-positionNegative')
    positionNegative:set(self.position):multiply(-1, -1, -1)
    self.transform:translate(self.transform, positionNegative)
    self.transform:transpose(self.transform)
    self.transform:mul(self.perspective, self.transform)
    return self
  end
})

return Camera
