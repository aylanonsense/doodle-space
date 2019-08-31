local cpml = require('libs/cpml')
local defineClass = require('utils/defineClass')

-- Vertex pools for calculating normals
local tempNormal1, tempNormal2 = cpml.vec3.new(), cpml.vec3.new()

local Shape = defineClass({
  vertices = nil,
  vertexMap = nil,
  init = function(self, vertices, vertexMap)
    self.vertices = vertices
    self.vertexMap = vertexMap
    -- Clean up the vertices
    for i, vertex in ipairs(self.vertices) do
      -- If no UV values were provided, make some up
      if not vertex[4] or not vertex[5] then
        local j = i % 6
        vertex[4] = (j == 1 or j == 2 or j == 4) and 1 or 0
        vertex[5] = (j == 2 or j == 4 or j == 5) and 1 or 0
      end
      -- If no normal vectors was provided, calculate some
      if not vertex[6] or not vertex[7] or not vertex[8] then
        -- Find every face the vertex is in
        if self.vertexMap then
          local sumVectors = cpml.vec3.new()
          for j = 1, #self.vertexMap, 3 do
            if self.vertexMap[j] == i or self.vertexMap[j + 1] == i or self.vertexMap[j + 2] == i then
              -- Get the three vertices that make up this face
              local v1, v2, v3 = self.vertices[self.vertexMap[j]], self.vertices[self.vertexMap[j + 1]], self.vertices[self.vertexMap[j + 2]]
              -- Find two lines on the polygon's plane
              tempNormal1.x, tempNormal1.y, tempNormal1.z = v3[1] - v2[1], v3[2] - v2[2], v3[3] - v2[3]
              tempNormal2.x, tempNormal2.y, tempNormal2.z = v2[1] - v1[1], v2[2] - v1[2], v2[3] - v1[3]
              -- Calculate the cross product
              local cross = cpml.vec3.cross(tempNormal1, tempNormal2):normalize()
              sumVectors.x, sumVectors.y, sumVectors.z = sumVectors.x + cross.x, sumVectors.y + cross.y, sumVectors.z + cross.z
            end
          end
          local normal = sumVectors:normalize()
          vertex[6], vertex[7], vertex[8] = normal.x, normal.y, normal.z
        else
          local j = math.floor((i - 1) / 3)
          -- Get the three vertices that make up this face
          local v1, v2, v3 = self.vertices[j * 3 + 1], self.vertices[j * 3 + 2], self.vertices[j * 3 + 3]
          -- Find two lines on the polygon's plane
          tempNormal1.x, tempNormal1.y, tempNormal1.z = v3[1] - v2[1], v3[2] - v2[2], v3[3] - v2[3]
          tempNormal2.x, tempNormal2.y, tempNormal2.z = v2[1] - v1[1], v2[2] - v1[2], v2[3] - v1[3]
          -- Calculate the cross product
          local normal = cpml.vec3.cross(tempNormal1, tempNormal2):normalize()
          vertex[6], vertex[7], vertex[8] = normal.x, normal.y, normal.z
        end
      end
    end
  end
})

-- Rectangles
local Rectangle = defineClass(Shape, {
  init = function(self, width, height)
    width = width or 1
    height = height or 1
    self.superclass.init(self, {
      -- Upper left
      { -width, height, 0, 0, 0 },
      -- Upper right
      { width, height, 0, 1, 0 },
      -- Lower left
      { -width, -height, 0, 0, 1 },
      -- Lower right
      { width, -height, 0, 1, 1 },
    }, {
      1, 2, 3,
      3, 2, 4
    })
  end
})
Shape.Rectangle = Rectangle:new()

local Cube = defineClass(Shape, {
  init = function(self, width, height, depth)
    width = width or 1
    height = height or 1
    depth = depth or 1
    self.superclass.init(self, {
      -- Front face
      { -width, height, depth, 0, 0 },
      { width, height, depth, 1, 0 },
      { -width, -height, depth, 0, 1 },
      { width, -height, depth, 1, 1 },
      -- Back face
      { width, height, -depth, 0, 0 },
      { -width, height, -depth, 1, 0 },
      { width, -height, -depth, 0, 1 },
      { -width, -height, -depth, 1, 1 },
      -- Top face
      { -width, height, -depth, 0, 0 },
      { width, height, -depth, 1, 0 },
      { -width, height, depth, 0, 1 },
      { width, height, depth, 1, 1 },
      -- Bottom face
      { -width, -height, depth, 0, 0 },
      { width, -height, depth, 1, 0 },
      { -width, -height, -depth, 0, 1 },
      { width, -height, -depth, 1, 1 },
      -- Left face
      { -width, height, -depth, 0, 0 },
      { -width, height, depth, 1, 0 },
      { -width, -height, -depth, 0, 1 },
      { -width, -height, depth, 1, 1 },
      -- Right face
      { width, height, depth, 0, 0 },
      { width, height, -depth, 1, 0 },
      { width, -height, depth, 0, 1 },
      { width, -height, -depth, 1, 1 },
    }, {
      1, 2, 3, 3, 2, 4,
      5, 6, 7, 7, 6, 8,
      9, 10, 11, 11, 10, 12,
      13, 14, 15, 15, 14, 16,
      17, 18, 19, 19, 18, 20,
      21, 22, 23, 23, 22, 24
    })
  end
})
Shape.Cube = Cube:new()

local Arrow = defineClass(Shape, {
  init = function(self, length)
    length = length or 1
    local a = 0.025
    local b = 0.05
    local c = length - 0.25
    local d = length
    self.superclass.init(self, {
      -- Back face
      { a, a, 0, 0, 0 },
      { -a, a, 0, 1, 0 },
      { a, -a, 0, 0, 1 },
      { -a, -a, 0, 1, 1 },
      -- Top face
      { -a, a, 0, 0, 0 },
      { a, a, 0, 1, 0 },
      { -a, a, c, 0, 1 },
      { a, a, c, 1, 1 },
      -- Bottom face
      { -a, -a, c, 0, 0 },
      { a, -a, c, 1, 0 },
      { -a, -a, 0, 0, 1 },
      { a, -a, 0, 1, 1 },
      -- Left face
      { -a, a, 0, 0, 0 },
      { -a, a, c, 1, 0 },
      { -a, -a, 0, 0, 1 },
      { -a, -a, c, 1, 1 },
      -- Right face
      { a, a, c, 0, 0 },
      { a, a, 0, 1, 0 },
      { a, -a, c, 0, 1 },
      { a, -a, 0, 1, 1 },
      -- Point
      { 0, 0, d },
      { -b, b, c },
      { b, b, c },
      { 0, 0, d },
      { b, -b, c },
      { -b, -b, c },
      { 0, 0, d },
      { -b, -b, c },
      { -b, b, c },
      { 0, 0, d },
      { b, b, c },
      { b, -b, c },
      -- Back of point
      { a, a, c },
      { -a, a, c },
      { a, -a, c },
      { -a, -a, c },
      { b, b, c },
      { -b, b, c },
      { b, -b, c },
      { -b, -b, c }
    }, {
      -- Faces
      1, 2, 3, 3, 2, 4,
      5, 6, 7, 7, 6, 8,
      9, 10, 11, 11, 10, 12,
      13, 14, 15, 15, 14, 16,
      17, 18, 19, 19, 18, 20,
      -- Point
      21, 22, 23,
      24, 25, 26,
      27, 28, 29,
      30, 31, 32,
      -- Back of point
      37, 34, 33, 38, 34, 37,
      33, 35, 39, 33, 39, 37,
      40, 35, 36, 40, 39, 35,
      36, 34, 38, 40, 36, 38
    })
  end
})
Shape.Arrow = Arrow:new()

return Shape
