local cpml = require('libs/cpml')
local defineClass = require('utils/defineClass')
local Shape = require('3d/Shape')
local vec3 = require('3d/vec3')
local textures = require('3d/textures')

-- Define vertex and polygon formats
local VERTEX_FORMAT = {
  { 'VertexPosition', 'float', 3 },
  { 'VertexTexCoord', 'float', 2 },
  { 'vertex_normal', 'float', 3 }
}
local POLYGON_FORMAT = 'triangles'

-- Objet pool
local tempVec = vec3()

local Model = defineClass({
  position = nil,
  rotation = nil,
  scale = nil,
  unitX = nil,
  unitY = nil,
  unitZ = nil,
  transform = nil,
  transformInverse = nil,
  mesh = nil,
  isWireframe = false,
  cullBackFacingPolygons = true,
  init = function(self, shape, texture)
    -- Set basic attributes
    self.position = vec3(0, 0, 0)
    self.rotation = vec3(0, 0, 0)
    self.scale = vec3(1, 1, 1)
    self.unitX = vec3(1, 0, 0)
    self.unitY = vec3(0, 1, 0)
    self.unitZ = vec3(0, 0, 1)

    -- Create a new mesh
    self.mesh = love.graphics.newMesh(VERTEX_FORMAT, shape.vertices, POLYGON_FORMAT)
    if shape.vertexMap then
      self.mesh:setVertexMap(shape.vertexMap)
    end
    self.mesh:setTexture(texture or textures.grey)

    -- Calculate the transformation matrix
    self.transform = cpml.mat4()
    self.transformInverse = cpml.mat4()
    self:calculateTransform()
  end,
  draw = function(self)
    love.graphics.setWireframe(self.isWireframe)
    love.graphics.setMeshCullMode(self.cullBackFacingPolygons and 'back' or 'none')
    love.graphics.draw(self.mesh)
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
      self.scale:multiplyValues(self.scale, x, y, z)
    else
      self.scale:multiply(self.scale, x)
    end
    return self
  end,
  setDirection = function(self, x, y, z)
    if y or z then
      self.rotation:dirToAngle(vec3(x, y, z)) -- Unnecessarily makes an extra object
    else
      self.rotation:dirToAngle(x)
    end
    return self
  end,
  setUpVector = function(self, up, forwardish)
    forwardish = forwardish or self.unitZ
    self.unitY:set(up)
    self.unitY:normalize(self.unitY)
    self.unitX:cross(self.unitY, forwardish)
    self.unitX:normalize(self.unitX)
    self.unitZ:cross(self.unitX, self.unitY)
    self.unitZ:normalize(self.unitZ)
    return self
  end,
  calculateTransform = function(self)
    self.transform:identity()
    -- Apply position
    self.transform:translate(self.transform, self.position)
    -- Apply change of unit vetors
    local unitRotation = tempVec:dirToAngle(self.unitZ, self.unitY)
    self.transform:rotate(self.transform, unitRotation[2], cpml.vec3.unit_y)
    self.transform:rotate(self.transform, unitRotation[1], cpml.vec3.unit_x)
    self.transform:rotate(self.transform, unitRotation[3], cpml.vec3.unit_z)
    -- Apply rotation
    self.transform:rotate(self.transform, self.rotation[2], cpml.vec3.unit_y)
    self.transform:rotate(self.transform, self.rotation[1], cpml.vec3.unit_x)
    self.transform:rotate(self.transform, self.rotation[3], cpml.vec3.unit_z)
    -- Apply scale
    self.transform:scale(self.transform, self.scale)
    -- Finish
    self.transform:transpose(self.transform)
    self.transformInverse:invert(self.transform)
    self.transformInverse:transpose(self.transformInverse)
    return self
  end
})

return Model
