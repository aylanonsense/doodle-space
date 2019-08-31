local cpml = require('libs/cpml')
local defineClass = require('utils/defineClass')

-- Define vertex and polygon formats
local VERTEX_FORMAT = {
  { 'VertexPosition', 'float', 3 },
  { 'VertexTexCoord', 'float', 2 },
  { 'vertex_normal', 'float', 3 }
}
local POLYGON_FORMAT = 'triangles'

-- Create a default black texture
local DEFAULT_TEXTURE = love.graphics.newCanvas(1,1)
love.graphics.setCanvas(DEFAULT_TEXTURE)
love.graphics.clear(0, 0, 0)
love.graphics.setCanvas()

local Model = defineClass({
  pos = nil,
  rotation = nil,
  size = nil,
  transform = nil,
  transformInverse = nil,
  mesh = nil,
  isWireframe = false,
  cullBackFacingPolygons = true,
  init = function(self, shape, texture)
    -- Set basic attributes
    self.pos = cpml.vec3.new(0, 0, 0)
    self.rotation = cpml.vec3.new(0, 0, 0)
    self.size = cpml.vec3.new(1, 1, 1)

    -- Create a new mesh
    self.mesh = love.graphics.newMesh(VERTEX_FORMAT, shape.vertices, POLYGON_FORMAT)
    if shape.vertexMap then
      self.mesh:setVertexMap(shape.vertexMap)
    end
    self.mesh:setTexture(texture or DEFAULT_TEXTURE)

    -- Immediately calculate the transformation matrix
    self:calculateTransform()
  end,
  draw = function(self)
    love.graphics.setWireframe(self.isWireframe)
    love.graphics.setMeshCullMode(self.cullBackFacingPolygons and 'back' or 'none')
    love.graphics.draw(self.mesh)
  end,
  setPosition = function(self, x, y, z)
    self.pos.x, self.pos.y, self.pos.z = x, y, z
  end,
  translate = function(self, x, y, z)
    self.pos.x, self.pos.y, self.pos.z = self.pos.x + x, self.pos.y + y, self.pos.z + z
  end,
  setRotation = function(self, x, y, z)
    self.rotation.x, self.rotation.y, self.rotation.z = x, y, z
  end,
  rotate = function(self, x, y, z)
    self.rotation.x, self.rotation.y, self.rotation.z = self.rotation.x + x, self.rotation.y + y, self.rotation.z + z
  end,
  calculateTransform = function(self)
    self.transform = cpml.mat4.identity()
    self.transform:translate(self.transform, self.pos)
    self.transform:rotate(self.transform, self.rotation.x, cpml.vec3.unit_x)
    self.transform:rotate(self.transform, self.rotation.y, cpml.vec3.unit_y)
    self.transform:rotate(self.transform, self.rotation.z, cpml.vec3.unit_z)
    self.transform:scale(self.transform, self.size)
    self.transform:transpose(self.transform)
    self.inverseTransform = self.transform.invert(cpml.mat4.new(), self.transform)
    self.inverseTransform:transpose(self.inverseTransform)
  end
})

return Model
