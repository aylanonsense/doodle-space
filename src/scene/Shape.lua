local defineClass = require('utils/defineClass')
local ObjectPool = require('util/ObjectPool')
local Vector3 = require('math/Vector3')

-- Object pool
local vector3Pool = ObjectPool:new(Vector3)

-- Define the class itself
local Shape = defineClass({
  vertices = nil,
  vertexMap = nil,
  init = function(self, vertices, vertexMap)
    self.vertices = vertices
    self.vertexMap = vertexMap
    self:cleanUpVertices()
  end,
  cleanUpVertices = function(self)
    for i, vertex in ipairs(self.vertices) do
      -- If no UV values were provided, make some up
      if not vertex[4] or not vertex[5] then
        local j = i % 6
        vertex[4] = (j == 1 or j == 2 or j == 4) and 1 or 0
        vertex[5] = (j == 2 or j == 4 or j == 5) and 1 or 0
      end
      -- If no normal vector was provided, calculate one
      if not vertex[6] or not vertex[7] or not vertex[8] then
        local normal = vector3Pool:withdraw('cleanUpVertices-normal')
        normal:zero()
        -- Find every face the vertex is in
        if self.vertexMap then
          -- Keep a sum of all normals
          for j = 1, #self.vertexMap, 3 do
            if self.vertexMap[j] == i or self.vertexMap[j + 1] == i or self.vertexMap[j + 2] == i then
              -- Get the three vertices that make up this face
              local v1, v2, v3 = self.vertices[self.vertexMap[j]], self.vertices[self.vertexMap[j + 1]], self.vertices[self.vertexMap[j + 2]]
              -- Find two lines on the polygon's plane
              local line1 = vector3Pool:withdraw('cleanUpVertices-line1')
              line1:set(v3[1], v3[2], v3[3]):subtract(v2[1], v2[2], v2[3])
              local line2 = vector3Pool:withdraw('cleanUpVertices-line2')
              line2:set(v2[1], v2[2], v2[3]):subtract(v1[1], v1[2], v1[3])
              -- Add the normal to the sum
              local cross = vector3Pool:withdraw('cleanUpVertices-cross')
              cross:set(line1):cross(line2):normalize()
              normal:add(cross)
            end
          end
          normal:normalize()
          vertex[6], vertex[7], vertex[8] = normal.x, normal.y, normal.z
        else
          local j = math.floor((i - 1) / 3)
          -- Get the three vertices that make up this face
          local v1, v2, v3 = self.vertices[j * 3 + 1], self.vertices[j * 3 + 2], self.vertices[j * 3 + 3]
          -- Find two lines on the polygon's plane
          local line1 = vector3Pool:withdraw('cleanUpVertices-line1')
          line1:set(v3[1], v3[2], v3[3]):subtract(v2[1], v2[2], v2[3])
          local line2 = vector3Pool:withdraw('cleanUpVertices-line2')
          line2:set(v2[1], v2[2], v2[3]):subtract(v1[1], v1[2], v1[3])
          -- Add the normal to the sum
          local normal = vector3Pool:withdraw('cleanUpVertices-normal')
          normal:set(line1):cross(line2):normalize()
          vertex[6], vertex[7], vertex[8] = normal.x, normal.y, normal.z
        end
      end
    end
  end
})

-- Rectangle
local Rectangle = defineClass(Shape, {
  init = function(self, width, height)
    width = width or 1
    height = height or 1
    Shape.init(self, {
      -- Upper left
      Vector3:new(-width,  height, 0, 0, 0),
      -- Upper right
      Vector3:new( width,  height, 0, 1, 0),
      -- Lower left
      Vector3:new(-width, -height, 0, 0, 1),
      -- Lower right
      Vector3:new( width, -height, 0, 1, 1)
    }, {
      1, 2, 3,
      3, 2, 4
    })
  end
})
Shape.Rectangle = Rectangle:new()

-- Cube
local Cube = defineClass(Shape, {
  init = function(self, width, height, depth)
    width = width or 1
    height = height or 1
    depth = depth or 1
    Shape.init(self, {
      -- Front face
      Vector3:new(-width,  height,  depth, 0, 0),
      Vector3:new( width,  height,  depth, 1, 0),
      Vector3:new(-width, -height,  depth, 0, 1),
      Vector3:new( width, -height,  depth, 1, 1),
      -- Back face
      Vector3:new( width,  height, -depth, 0, 0),
      Vector3:new(-width,  height, -depth, 1, 0),
      Vector3:new( width, -height, -depth, 0, 1),
      Vector3:new(-width, -height, -depth, 1, 1),
      -- Top face
      Vector3:new(-width,  height, -depth, 0, 0),
      Vector3:new( width,  height, -depth, 1, 0),
      Vector3:new(-width,  height,  depth, 0, 1),
      Vector3:new( width,  height,  depth, 1, 1),
      -- Bottom face
      Vector3:new(-width, -height,  depth, 0, 0),
      Vector3:new( width, -height,  depth, 1, 0),
      Vector3:new(-width, -height, -depth, 0, 1),
      Vector3:new( width, -height, -depth, 1, 1),
      -- Left face
      Vector3:new(-width,  height, -depth, 0, 0),
      Vector3:new(-width,  height,  depth, 1, 0),
      Vector3:new(-width, -height, -depth, 0, 1),
      Vector3:new(-width, -height,  depth, 1, 1),
      -- Right face
      Vector3:new( width,  height,  depth, 0, 0),
      Vector3:new( width,  height, -depth, 1, 0),
      Vector3:new( width, -height,  depth, 0, 1),
      Vector3:new( width, -height, -depth, 1, 1)
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

-- Arrow
local Arrow = defineClass(Shape, {
  init = function(self, length)
    length = length or 1
    local a = 0.025
    local b = 0.1
    local c = length - 0.35
    local d = length
    Shape.init(self, {
      -- Back face
      Vector3:new( a,  a,  0),
      Vector3:new(-a,  a,  0),
      Vector3:new( a, -a,  0),
      Vector3:new(-a, -a,  0),
      -- Top face
      Vector3:new(-a,  a,  0),
      Vector3:new( a,  a,  0),
      Vector3:new(-a,  a,  c),
      Vector3:new( a,  a,  c),
      -- Bottom face
      Vector3:new(-a, -a,  c),
      Vector3:new( a, -a,  c),
      Vector3:new(-a, -a,  0),
      Vector3:new( a, -a,  0),
      -- Left face
      Vector3:new(-a,  a,  0),
      Vector3:new(-a,  a,  c),
      Vector3:new(-a, -a,  0),
      Vector3:new(-a, -a,  c),
      -- Right face
      Vector3:new( a,  a,  c),
      Vector3:new( a,  a,  0),
      Vector3:new( a, -a,  c),
      Vector3:new( a, -a,  0),
      -- Point
      Vector3:new( 0,  0,  d),
      Vector3:new(-b,  b,  c),
      Vector3:new( b,  b,  c),
      Vector3:new( 0,  0,  d),
      Vector3:new( b, -b,  c),
      Vector3:new(-b, -b,  c),
      Vector3:new( 0,  0,  d),
      Vector3:new(-b, -b,  c),
      Vector3:new(-b,  b,  c),
      Vector3:new( 0,  0,  d),
      Vector3:new( b,  b,  c),
      Vector3:new( b, -b,  c),
      -- Back of point
      Vector3:new( a,  a,  c),
      Vector3:new(-a,  a,  c),
      Vector3:new( a, -a,  c),
      Vector3:new(-a, -a,  c),
      Vector3:new( b,  b,  c),
      Vector3:new(-b,  b,  c),
      Vector3:new( b, -b,  c),
      Vector3:new(-b, -b,  c)
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
Shape.Arrow = Arrow:new(10)

-- Icosahedron
local Icosahedron = defineClass(Shape, {
  init = function(self)
    local a = 1
    local b = 1 / ((1 + math.sqrt(5)) / 2)
    Shape.init(self, {
      Vector3:new(-a,  0,  b),
      Vector3:new(-b,  a,  0),
      Vector3:new( 0,  b,  a),
      Vector3:new( 0,  b,  a),
      Vector3:new(-b,  a,  0),
      Vector3:new( b,  a,  0),
      Vector3:new( b,  a,  0),
      Vector3:new(-b,  a,  0),
      Vector3:new( 0,  b, -a),
      Vector3:new( 0,  b, -a),
      Vector3:new(-b,  a,  0),
      Vector3:new(-a,  0, -b),
      Vector3:new(-a,  0, -b),
      Vector3:new(-b,  a,  0),
      Vector3:new(-a,  0,  b),
      Vector3:new( 0,  b,  a),
      Vector3:new( b,  a,  0),
      Vector3:new( a,  0,  b),
      Vector3:new(-a,  0,  b),
      Vector3:new( 0,  b,  a),
      Vector3:new( 0, -b,  a),
      Vector3:new(-a,  0, -b),
      Vector3:new(-a,  0,  b),
      Vector3:new(-b, -a,  0),
      Vector3:new( 0,  b, -a),
      Vector3:new(-a,  0, -b),
      Vector3:new( 0, -b, -a),
      Vector3:new( b,  a,  0),
      Vector3:new( 0,  b, -a),
      Vector3:new( a,  0, -b),
      Vector3:new( a,  0,  b),
      Vector3:new( b, -a,  0),
      Vector3:new( 0, -b,  a),
      Vector3:new( 0, -b,  a),
      Vector3:new( b, -a,  0),
      Vector3:new(-b, -a,  0),
      Vector3:new(-b, -a,  0),
      Vector3:new( b, -a,  0),
      Vector3:new( 0, -b, -a),
      Vector3:new( 0, -b, -a),
      Vector3:new( b, -a,  0),
      Vector3:new( a,  0, -b),
      Vector3:new( a,  0, -b),
      Vector3:new( b, -a,  0),
      Vector3:new( a,  0,  b),
      Vector3:new( a,  0,  b),
      Vector3:new( 0, -b,  a),
      Vector3:new( 0,  b,  a),
      Vector3:new( 0, -b,  a),
      Vector3:new(-b, -a,  0),
      Vector3:new(-a,  0,  b),
      Vector3:new(-b, -a,  0),
      Vector3:new( 0, -b, -a),
      Vector3:new(-a,  0, -b),
      Vector3:new( 0, -b, -a),
      Vector3:new( a,  0, -b),
      Vector3:new( 0,  b, -a),
      Vector3:new( a,  0, -b),
      Vector3:new( a,  0,  b),
      Vector3:new( b,  a,  0)
    })
  end
})
Shape.Icosahedron = Icosahedron:new()

-- Sphere
local Sphere = defineClass(Icosahedron, {
  init = function(self, subdivisions)
    subdivisions = subdivisions or 1
    -- Start from a Icosahedron
    Icosahedron.init(self)
    -- Move all the vertices to be on the unit circle
    for _, vertex in ipairs(self.vertices) do
      vertex:normalize()
    end
    -- Repeatedly subdivide every face
    for i = 1, subdivisions do
      local subdividedVertices = {}
      for j = 1, #self.vertices, 3 do
        local vec1, vec2, vec3 = self.vertices[j], self.vertices[j + 1], self.vertices[j + 2]
        -- Find the midpoint of each edge
        local midpoint1 = vector3Pool:withdraw('Sphere-midpoint1')
        midpoint1:set(vec1):add(vec2):divide(2, 2, 2)
        local midpoint2 = vector3Pool:withdraw('Sphere-midpoint2')
        midpoint2:set(vec2):add(vec3):divide(2, 2, 2)
        local midpoint3 = vector3Pool:withdraw('Sphere-midpoint3')
        midpoint3:set(vec1):add(vec3):divide(2, 2, 2)
        -- Add the new faces
        table.insert(subdividedVertices, midpoint1:clone())
        table.insert(subdividedVertices, midpoint2:clone())
        table.insert(subdividedVertices, midpoint3:clone())
        table.insert(subdividedVertices, vec1:clone())
        table.insert(subdividedVertices, midpoint1:clone())
        table.insert(subdividedVertices, midpoint3:clone())
        table.insert(subdividedVertices, vec2:clone())
        table.insert(subdividedVertices, midpoint2:clone())
        table.insert(subdividedVertices, midpoint1:clone())
        table.insert(subdividedVertices, vec3:clone())
        table.insert(subdividedVertices, midpoint3:clone())
        table.insert(subdividedVertices, midpoint2:clone())
      end
      self.vertices = subdividedVertices
      -- Move all the vertices to be on the unit circle
      for _, vertex in ipairs(self.vertices) do
        vertex:normalize()
      end
    end
    self:cleanUpVertices()
  end
})
Shape.Sphere = Sphere:new(2)

-- Debug cube person
local CubePerson = defineClass(Shape, {
  init = function(self)
    local bodyTopLeft = -1.0
    local bodyTopRight = 1.0
    local bodyBottomLeft = -0.6
    local bodyBottomRight = 0.6
    local bodyTop = 0.1
    local bodyBottom = -1.0
    local bodyFront = 0.4
    local bodyBack = -0.4

    local headLeft = -0.4
    local headRight = 0.4
    local headTop = 1.0
    local headBottom = 0.2
    local headFront = 0.4
    local headBack = -0.4

    local armLeft = -0.9
    local armRight = -0.4
    local armTop = 0.1
    local armBottom = -0.4
    local armFront = 2.0
    local armBack = 0.5

    Shape.init(self, {
      -- Body front face
      Vector3:new(bodyTopLeft,     bodyTop,    bodyFront, 0, 0),
      Vector3:new(bodyTopRight,    bodyTop,    bodyFront, 1, 0),
      Vector3:new(bodyBottomLeft,  bodyBottom, bodyFront, 0, 1),
      Vector3:new(bodyBottomRight, bodyBottom, bodyFront, 1, 1),
      -- Body back face
      Vector3:new(bodyTopRight,    bodyTop,    bodyBack,  0, 0),
      Vector3:new(bodyTopLeft,     bodyTop,    bodyBack,  1, 0),
      Vector3:new(bodyBottomRight, bodyBottom, bodyBack,  0, 1),
      Vector3:new(bodyBottomLeft,  bodyBottom, bodyBack,  1, 1),
      -- Body top face
      Vector3:new(bodyTopLeft,     bodyTop,    bodyBack,  0, 0),
      Vector3:new(bodyTopRight,    bodyTop,    bodyBack,  1, 0),
      Vector3:new(bodyTopLeft,     bodyTop,    bodyFront, 0, 1),
      Vector3:new(bodyTopRight,    bodyTop,    bodyFront, 1, 1),
      -- Body bottom face
      Vector3:new(bodyBottomLeft,  bodyBottom, bodyFront, 0, 0),
      Vector3:new(bodyBottomRight, bodyBottom, bodyFront, 1, 0),
      Vector3:new(bodyBottomLeft,  bodyBottom, bodyBack,  0, 1),
      Vector3:new(bodyBottomRight, bodyBottom, bodyBack,  1, 1),
      -- Body left face
      Vector3:new(bodyTopLeft,     bodyTop,    bodyBack,  0, 0),
      Vector3:new(bodyTopLeft,     bodyTop,    bodyFront, 1, 0),
      Vector3:new(bodyBottomLeft,  bodyBottom, bodyBack,  0, 1),
      Vector3:new(bodyBottomLeft,  bodyBottom, bodyFront, 1, 1),
      -- Body right face
      Vector3:new(bodyTopRight,    bodyTop,    bodyFront, 0, 0),
      Vector3:new(bodyTopRight,    bodyTop,    bodyBack,  1, 0),
      Vector3:new(bodyBottomRight, bodyBottom, bodyFront, 0, 1),
      Vector3:new(bodyBottomRight, bodyBottom, bodyBack,  1, 1),

      -- Head front face
      Vector3:new(headLeft,  headTop,    headFront, 0, 0),
      Vector3:new(headRight, headTop,    headFront, 1, 0),
      Vector3:new(headLeft,  headBottom, headFront, 0, 1),
      Vector3:new(headRight, headBottom, headFront, 1, 1),
      -- Head back face
      Vector3:new(headRight, headTop,    headBack,  0, 0),
      Vector3:new(headLeft,  headTop,    headBack,  1, 0),
      Vector3:new(headRight, headBottom, headBack,  0, 1),
      Vector3:new(headLeft,  headBottom, headBack,  1, 1),
      -- Head top face
      Vector3:new(headLeft,  headTop,    headBack,  0, 0),
      Vector3:new(headRight, headTop,    headBack,  1, 0),
      Vector3:new(headLeft,  headTop,    headFront, 0, 1),
      Vector3:new(headRight, headTop,    headFront, 1, 1),
      -- Head bottom face
      Vector3:new(headLeft,  headBottom, headFront, 0, 0),
      Vector3:new(headRight, headBottom, headFront, 1, 0),
      Vector3:new(headLeft,  headBottom, headBack,  0, 1),
      Vector3:new(headRight, headBottom, headBack,  1, 1),
      -- Head left face
      Vector3:new(headLeft,  headTop,    headBack,  0, 0),
      Vector3:new(headLeft,  headTop,    headFront, 1, 0),
      Vector3:new(headLeft,  headBottom, headBack,  0, 1),
      Vector3:new(headLeft,  headBottom, headFront, 1, 1),
      -- Head right face
      Vector3:new(headRight, headTop,    headFront, 0, 0),
      Vector3:new(headRight, headTop,    headBack,  1, 0),
      Vector3:new(headRight, headBottom, headFront, 0, 1),
      Vector3:new(headRight, headBottom, headBack,  1, 1),

      -- Arm front face
      Vector3:new(armLeft,  armTop,    armFront, 0, 0),
      Vector3:new(armRight, armTop,    armFront, 1, 0),
      Vector3:new(armLeft,  armBottom, armFront, 0, 1),
      Vector3:new(armRight, armBottom, armFront, 1, 1),
      -- Arm back face
      Vector3:new(armRight, armTop,    armBack,  0, 0),
      Vector3:new(armLeft,  armTop,    armBack,  1, 0),
      Vector3:new(armRight, armBottom, armBack,  0, 1),
      Vector3:new(armLeft,  armBottom, armBack,  1, 1),
      -- Arm top face
      Vector3:new(armLeft,  armTop,    armBack,  0, 0),
      Vector3:new(armRight, armTop,    armBack,  1, 0),
      Vector3:new(armLeft,  armTop,    armFront, 0, 1),
      Vector3:new(armRight, armTop,    armFront, 1, 1),
      -- Arm bottom face
      Vector3:new(armLeft,  armBottom, armFront, 0, 0),
      Vector3:new(armRight, armBottom, armFront, 1, 0),
      Vector3:new(armLeft,  armBottom, armBack,  0, 1),
      Vector3:new(armRight, armBottom, armBack,  1, 1),
      -- Arm left face
      Vector3:new(armLeft,  armTop,    armBack,  0, 0),
      Vector3:new(armLeft,  armTop,    armFront, 1, 0),
      Vector3:new(armLeft,  armBottom, armBack,  0, 1),
      Vector3:new(armLeft,  armBottom, armFront, 1, 1),
      -- Arm right face
      Vector3:new(armRight, armTop,    armFront, 0, 0),
      Vector3:new(armRight, armTop,    armBack,  1, 0),
      Vector3:new(armRight, armBottom, armFront, 0, 1),
      Vector3:new(armRight, armBottom, armBack,  1, 1)
    }, {
      1, 2, 3, 3, 2, 4,
      5, 6, 7, 7, 6, 8,
      9, 10, 11, 11, 10, 12,
      13, 14, 15, 15, 14, 16,
      17, 18, 19, 19, 18, 20,
      21, 22, 23, 23, 22, 24,

      25, 26, 27, 27, 26, 28,
      29, 30, 31, 31, 30, 32,
      33, 34, 35, 35, 34, 36,
      37, 38, 39, 39, 38, 40,
      41, 42, 43, 43, 42, 44,
      45, 46, 47, 47, 46, 48,

      49, 50, 51, 51, 50, 52,
      53, 54, 55, 55, 54, 56,
      57, 58, 59, 59, 58, 60,
      61, 62, 63, 63, 62, 64,
      65, 66, 67, 67, 66, 68,
      69, 70, 71, 71, 70, 72
    })
  end
})
Shape.CubePerson = CubePerson:new()

return Shape
