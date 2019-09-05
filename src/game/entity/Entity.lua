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

-- Object pool
local tempVec = vec3()
local tempVec2 = vec3()
local tempVec3 = vec3()
local tempDrawVec = vec3()
local tempConversionObj = {}
local tempAbsoluteVec = vec3()
local tempRelativeVec = vec3()

local Entity = defineClass({
  position = nil,
  rotation = nil,
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
      self.model:setPosition(self.position):setRotation(self.rotation):setScale(self.scale):calculateTransform():draw(shader)
    end
  end,
  drawAxis = function(self, shader)
    axisArrowX:setPosition(self.position):setDirection(self.axisX):calculateTransform():draw(shader)
    axisArrowY:setPosition(self.position):setDirection(self.axisY):calculateTransform():draw(shader)
    axisArrowZ:setPosition(self.position):setDirection(self.axisZ):calculateTransform():draw(shader)
  end,
  setAxis = function(self, upX, upY, upZ, forwardX, forwardY, forwardZ)
    local axisX = tempVec
    local axisY = tempVec2
    local axisZ = tempVec3
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
    upX = upX or 0
    upY = upY or 0
    upZ = upZ or 0
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
    -- Create a transformation matrix
    self.axisX:set(axisX)
    self.axisY:set(axisY)
    self.axisZ:set(axisZ)
    self.axisRotation:dirToAngle(self.axisZ, self.axisY)
    self.axisTransform:identity()
    self.axisTransform:rotate(self.axisTransform, self.axisRotation[2], cpml.vec3.unit_y)
    self.axisTransform:rotate(self.axisTransform, self.axisRotation[1], cpml.vec3.unit_x)
    self.axisTransform:rotate(self.axisTransform, self.axisRotation[3], cpml.vec3.unit_z)
    self.axisTransformInverse:invert(self.axisTransform)
    return self
  end,
  getPosition = function(self, out)
    out = out or vec3()
    out[1], out[2], out[3] = self.position.x, self.position.y, self.position.z
    return out
  end,
  getPositionRelative = function(self, out)
    return self:convertToAbsolute(out or vec3(), self.position)
  end,
  setPosition = function(self, x, y, z)
    if y or z then
      self.position:setValues(x, y, z)
    else
      self.position:set(x)
    end
    return self
  end,
  setPositionRelative = function(self, x, y, z)
    return self:setPosition(0, 0, 0):translateRelative(x, y, z)
  end,
  translate = function(self, x, y, z)
    if y or z then
      self.position:addValues(self.position, x, y, z)
    else
      self.position:add(self.position, x)
    end
    return self
  end,
  translateRelative = function(self, x, y, z)
    return self:translate(self:convertToAbsolute(tempVec, x, y, z))
  end,
  getRotation = function(self, out)
    out = out or vec3()
    out[1], out[2], out[3] = self.rotation.x, self.rotation.y, self.rotation.z
    return out
  end,
  getRotationRelative = function(self, scene, out) -- TODO rmeove scene
    -- Create a rotation matrix
    local rotation = cpml.mat4()
    rotation:identity()
    rotation:rotate(rotation, self.rotation[2], cpml.vec3.unit_y)
    rotation:rotate(rotation, self.rotation[1], cpml.vec3.unit_x)
    rotation:rotate(rotation, self.rotation[3], cpml.vec3.unit_z)
    -- Create the axis direction
    local forward = vec3(0, 0, 1)
    local up = vec3(0, 1, 0)
    local side = vec3(1, 0, 0)
    -- Apply the rotation to each of them
    forward:applyTransform(forward, rotation)
    up:applyTransform(up, rotation)
    side:applyTransform(side, rotation)
    -- Project the side axis onto the XZ plane
    local normal = vec3()
    normal:cross(forward, vec3(0, up.y >= 0 and 1 or -1, 0))
    normal:cross(normal, forward)
    local sideProj = vec3()
    sideProj:projectOntoPlane(side, normal)
    if up.y < 0 then
      sideProj:multiplyValues(sideProj, -1, -1, -1)
    end
    -- print('sideProj', sideProj)
    -- -- The angle between the side and its XZ projection is the roll
    local angle = sideProj:angleBetween(side, forward)
    print('rotation', self.rotation)
    print('forward', forward)
    print('vector', vec3():angleToDir(self.rotation))
    print('self.rotation[3]', self.rotation[3])
    print('angle', angle)
    print('pi - angle', math.pi - math.abs(angle))
    scene:addArrowInDirection(self.position, forward, 4 * forward:length(), textures.blue)
    scene:addArrowInDirection(self.position, up, 4 * up:length(), textures.green)
    scene:addArrowInDirection(self.position, side, 4 * side:length(), textures.red)
    scene:addArrowInDirection(self.position, normal, 4 * normal:length())
    scene:addArrowInDirection(self.position, sideProj, 4 * sideProj:length(), textures.yellow)
    -- self.axisX = side
    -- self.axisZ = normal
    -- self.axisY = sideProj
    -- local dir = vec3():angleToDir(self.rotation)
    -- local handle = vec3():cross(dir, { 0, 1, 0 })
    -- TODO
    -- out = out or vec3()
    -- return out:subtract(self.rotation, self.axisRotation)
  end,
  setRotation = function(self, x, y, z)
    if y or z then
      self.rotation:setValues(x, y, z)
    else
      self.rotation:set(x)
    end
    return self
  end,
  setRotationRelative = function(self, x, y, z)
    if not y and not z then
      x, y, z = x[1], x[2], x[3]
    end
    return self:setRotation(self.axisRotation):rotateRelative(x, y, z)
  end,
  rotate = function(self, x, y, z)
    if y or z then
      self.rotation:addValues(self.rotation, x, y, z)
    else
      self.rotation:add(self.rotation, x)
    end
    return self
  end,
  rotateRelative = function(self, x, y, z)
    if not y and not z then
      x, y, z = x[1], x[2], x[3]
    end
    -- Convert the current rotation to a direction
    local dir = vec3():angleToDir(self.rotation)
    -- Convert the direction to relative
    local dirRelative = self:convertToRelative(vec3(), dir)
    -- Apply the rotation
    local transform = cpml.mat4()
    transform:identity()
    transform:rotate(transform, y, cpml.vec3.unit_y)
    transform:rotate(transform, x, cpml.vec3.unit_x)
    transform:rotate(transform, z, cpml.vec3.unit_z)
    dirRelative:applyTransform(dirRelative, transform)
    -- Convert it back to absolute
    local dirAbsolute = self:convertToAbsolute(vec3(), dirRelative)
    -- Convert it back to an angle
    local angleAbsolute = vec3():dirToAngle(dirAbsolute)
    -- Set it
    self:setRotation(angleAbsolute[1], angleAbsolute[2], self.rotation[3] + z)
    return self
  end,
  -- getDirection = function(self, out)
    -- out = out or vec3()
    -- out[1], out[2], out[3] = self.direction.x, self.direction.y, self.direction.z
    -- return out
  -- end,
  -- getDirectionRelative = function(self, out)
    -- return self:convertToAbsolute(out or vec3(), self.direction)
  -- end,
  -- setDirection = function(self, x, y, z)
    -- if y or z then
    --   self.direction:setValues(x, y, z)
    -- else
    --   self.direction:set(x)
    -- end
    -- self.direction:normalize(self.direction)
    -- return self
  -- end,
  -- setDirectionRelative = function(self, x, y, z)
    -- return self:setDirection(0, 0, 0):rotateRelative(x, y, z)
  -- end,
  getVelocity = function(self, out)
    out = out or vec3()
    out[1], out[2], out[3] = self.velocity.x, self.velocity.y, self.velocity.z
    return out
  end,
  getVelocityRelative = function(self, out)
    return self:convertToAbsolute(out or vec3(), self.velocity)
  end,
  setVelocity = function(self, x, y, z)
    if y or z then
      self.velocity:setValues(x, y, z)
    else
      self.velocity:set(x)
    end
    return self
  end,
  setVelocityRelative = function(self, x, y, z)
    return self:setVelocity(0, 0, 0):accelerateRelative(x, y, z)
  end,
  accelerate = function(self, x, y, z)
    if y or z then
      self.velocity:addValues(self.velocity, x, y, z)
    else
      self.velocity:add(self.velocity, x)
    end
    return self
  end,
  accelerateRelative = function(self, x, y, z)
    return self:accelerate(self:convertToAbsolute(tempVec, x, y, z))
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
  resize = function(self, x, y, z)
    if y or z then
      self.scale:addValues(self.scale, x, y, z)
    else
      self.scale:add(self.scale, x)
    end
    return self
  end,
  -- Turns a vector relative to the entity's axis to an absolute one
  convertToAbsolute = function(self, out, x, y, z)
    if y or z then
      tempAbsoluteVec:setValues(x, y, z)
    else
      tempAbsoluteVec:set(x)
    end
    -- Multiply by the axis transformation
    tempAbsoluteVec:applyTransform(tempAbsoluteVec, self.axisTransform)
    -- The result is the now-absolute vector
    out[1], out[2], out[3] = tempAbsoluteVec[1], tempAbsoluteVec[2], tempAbsoluteVec[3]
    return out
  end,
  -- Turns a vector into one that's relative to the entity's axis
  convertToRelative = function(self, out, x, y, z)
    -- Create a vec4 from the input
    if y or z then
      tempRelativeVec:setValues(x, y, z)
    else
      tempRelativeVec:set(x)
    end
    -- Multiply by the inverse axis transformation
    tempRelativeVec:applyTransform(tempRelativeVec, self.axisTransformInverse)
    -- The result is the now-relative vector
    out[1], out[2], out[3] = tempRelativeVec[1], tempRelativeVec[2], tempRelativeVec[3]
    return out
  end
})

return Entity
