local defineClass = require('utils/defineClass')
local SceneObject = require('scene/SceneObject')
local textures = require('scene/textures')

-- Define vertex and polygon formats
local VERTEX_FORMAT = {
  { 'VertexPosition', 'float', 3 },
  { 'VertexTexCoord', 'float', 2 },
  { 'vertex_normal', 'float', 3 }
}
local POLYGON_FORMAT = 'triangles'

local Model = defineClass(SceneObject, {
  mesh = nil,
  isWireframe = false,
  cullBackFacingPolygons = true,
  isVisible = true,
  init = function(self, shape, texture)
    texture = texture or textures.black

    -- Initialize
    SceneObject.init(self)

    -- Create a new mesh
    self.mesh = love.graphics.newMesh(VERTEX_FORMAT, shape.vertices, POLYGON_FORMAT)
    if shape.vertexMap then
      self.mesh:setVertexMap(shape.vertexMap)
    end
    self.mesh:setTexture(texture or textures.black)
  end,
  draw = function(self)
    self.scene.shader:send('model_transform', self.transform)
    self.scene.shader:send('model_transform_inverse', self.transformInverse)
    love.graphics.setWireframe(self.isWireframe)
    love.graphics.setMeshCullMode(self.cullBackFacingPolygons and 'back' or 'none')
    love.graphics.draw(self.mesh)
  end
})

return Model
