local vec3 = require('3d/vec3')
local defineClass = require('utils/defineClass')
local tableUtils = require('utils/table')

-- Object pool
local vecPool1, vecPool2, vecPool3 = vec3(), vec3(), vec3()

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
      -- If no normal vectors was provided, calculate some
      if not vertex[6] or not vertex[7] or not vertex[8] then
        -- Find every face the vertex is in
        if self.vertexMap then
          -- Keep a sum of all normals
          vecPool3:zero()
          for j = 1, #self.vertexMap, 3 do
            if self.vertexMap[j] == i or self.vertexMap[j + 1] == i or self.vertexMap[j + 2] == i then
              -- Get the three vertices that make up this face
              local v1, v2, v3 = self.vertices[self.vertexMap[j]], self.vertices[self.vertexMap[j + 1]], self.vertices[self.vertexMap[j + 2]]
              -- Find two lines on the polygon's plane
              vecPool1:subtract(v3, v2)
              vecPool2:subtract(v2, v1)
              -- Add the normal to the sume
              vecPool1:cross(vecPool1, vecPool2)
              vecPool1:normalize(vecPool1)
              vecPool3:add(vecPool3, vecPool1)
            end
          end
          vecPool3:normalize(vecPool3)
          vertex[6], vertex[7], vertex[8] = vecPool3[1], vecPool3[2], vecPool3[3]
        else
          local j = math.floor((i - 1) / 3)
          -- Get the three vertices that make up this face
          local v1, v2, v3 = self.vertices[j * 3 + 1], self.vertices[j * 3 + 2], self.vertices[j * 3 + 3]
          -- Find two lines on the polygon's plane
          vecPool1:subtract(v3, v2)
          vecPool2:subtract(v2, v1)
          -- Calculate the cross product
          vecPool1:cross(vecPool1, vecPool2)
          vecPool1:normalize(vecPool1)
          vertex[6], vertex[7], vertex[8] = vecPool1[1], vecPool1[2], vecPool1[3]
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
    Shape.init(self, {
      -- Upper left
      vec3(-width,  height, 0, 0, 0),
      -- Upper right
      vec3( width,  height, 0, 1, 0),
      -- Lower left
      vec3(-width, -height, 0, 0, 1),
      -- Lower right
      vec3( width, -height, 0, 1, 1)
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
    Shape.init(self, {
      -- Front face
      vec3(-width,  height,  depth, 0, 0),
      vec3( width,  height,  depth, 1, 0),
      vec3(-width, -height,  depth, 0, 1),
      vec3( width, -height,  depth, 1, 1),
      -- Back face
      vec3( width,  height, -depth, 0, 0),
      vec3(-width,  height, -depth, 1, 0),
      vec3( width, -height, -depth, 0, 1),
      vec3(-width, -height, -depth, 1, 1),
      -- Top face
      vec3(-width,  height, -depth, 0, 0),
      vec3( width,  height, -depth, 1, 0),
      vec3(-width,  height,  depth, 0, 1),
      vec3( width,  height,  depth, 1, 1),
      -- Bottom face
      vec3(-width, -height,  depth, 0, 0),
      vec3( width, -height,  depth, 1, 0),
      vec3(-width, -height, -depth, 0, 1),
      vec3( width, -height, -depth, 1, 1),
      -- Left face
      vec3(-width,  height, -depth, 0, 0),
      vec3(-width,  height,  depth, 1, 0),
      vec3(-width, -height, -depth, 0, 1),
      vec3(-width, -height,  depth, 1, 1),
      -- Right face
      vec3( width,  height,  depth, 0, 0),
      vec3( width,  height, -depth, 1, 0),
      vec3( width, -height,  depth, 0, 1),
      vec3( width, -height, -depth, 1, 1)
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
    local b = 0.1
    local c = length - 0.35
    local d = length
    Shape.init(self, {
      -- Back face
      vec3( a,  a,  0),
      vec3(-a,  a,  0),
      vec3( a, -a,  0),
      vec3(-a, -a,  0),
      -- Top face
      vec3(-a,  a,  0),
      vec3( a,  a,  0),
      vec3(-a,  a,  c),
      vec3( a,  a,  c),
      -- Bottom face
      vec3(-a, -a,  c),
      vec3( a, -a,  c),
      vec3(-a, -a,  0),
      vec3( a, -a,  0),
      -- Left face
      vec3(-a,  a,  0),
      vec3(-a,  a,  c),
      vec3(-a, -a,  0),
      vec3(-a, -a,  c),
      -- Right face
      vec3( a,  a,  c),
      vec3( a,  a,  0),
      vec3( a, -a,  c),
      vec3( a, -a,  0),
      -- Point
      vec3( 0,  0,  d),
      vec3(-b,  b,  c),
      vec3( b,  b,  c),
      vec3( 0,  0,  d),
      vec3( b, -b,  c),
      vec3(-b, -b,  c),
      vec3( 0,  0,  d),
      vec3(-b, -b,  c),
      vec3(-b,  b,  c),
      vec3( 0,  0,  d),
      vec3( b,  b,  c),
      vec3( b, -b,  c),
      -- Back of point
      vec3( a,  a,  c),
      vec3(-a,  a,  c),
      vec3( a, -a,  c),
      vec3(-a, -a,  c),
      vec3( b,  b,  c),
      vec3(-b,  b,  c),
      vec3( b, -b,  c),
      vec3(-b, -b,  c)
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

local Icosahedron = defineClass(Shape, {
  init = function(self)
    local a = 1
    local b = 1 / ((1 + math.sqrt(5)) / 2)
    Shape.init(self, {
      vec3(-a,  0,  b),
      vec3(-b,  a,  0),
      vec3( 0,  b,  a),
      vec3( 0,  b,  a),
      vec3(-b,  a,  0),
      vec3( b,  a,  0),
      vec3( b,  a,  0),
      vec3(-b,  a,  0),
      vec3( 0,  b, -a),
      vec3( 0,  b, -a),
      vec3(-b,  a,  0),
      vec3(-a,  0, -b),
      vec3(-a,  0, -b),
      vec3(-b,  a,  0),
      vec3(-a,  0,  b),
      vec3( 0,  b,  a),
      vec3( b,  a,  0),
      vec3( a,  0,  b),
      vec3(-a,  0,  b),
      vec3( 0,  b,  a),
      vec3( 0, -b,  a),
      vec3(-a,  0, -b),
      vec3(-a,  0,  b),
      vec3(-b, -a,  0),
      vec3( 0,  b, -a),
      vec3(-a,  0, -b),
      vec3( 0, -b, -a),
      vec3( b,  a,  0),
      vec3( 0,  b, -a),
      vec3( a,  0, -b),
      vec3( a,  0,  b),
      vec3( b, -a,  0),
      vec3( 0, -b,  a),
      vec3( 0, -b,  a),
      vec3( b, -a,  0),
      vec3(-b, -a,  0),
      vec3(-b, -a,  0),
      vec3( b, -a,  0),
      vec3( 0, -b, -a),
      vec3( 0, -b, -a),
      vec3( b, -a,  0),
      vec3( a,  0, -b),
      vec3( a,  0, -b),
      vec3( b, -a,  0),
      vec3( a,  0,  b),
      vec3( a,  0,  b),
      vec3( 0, -b,  a),
      vec3( 0,  b,  a),
      vec3( 0, -b,  a),
      vec3(-b, -a,  0),
      vec3(-a,  0,  b),
      vec3(-b, -a,  0),
      vec3( 0, -b, -a),
      vec3(-a,  0, -b),
      vec3( 0, -b, -a),
      vec3( a,  0, -b),
      vec3( 0,  b, -a),
      vec3( a,  0, -b),
      vec3( a,  0,  b),
      vec3( b,  a,  0)
    })
  end
})
Shape.Icosahedron = Icosahedron:new()

local Sphere = defineClass(Icosahedron, {
  init = function(self, subdivisions)
    subdivisions = subdivisions or 1
    Icosahedron.init(self)
    -- Move all vertices to be on the unit ciircle
    for _, vertex in ipairs(self.vertices) do
      vec3.normalize(vertex, vertex)
    end
    -- Repeatedly subdivide every face
    for subdivides = 1, subdivisions do
      local subdividedVertices = {}
      for i = 1, #self.vertices, 3 do
        local v1, v2, v3 = self.vertices[i], self.vertices[i + 1], self.vertices[i + 2]
        vecPool1:average(v1, v2)
        vecPool2:average(v2, v3)
        vecPool3:average(v1, v3)
        table.insert(subdividedVertices, vecPool1:clone())
        table.insert(subdividedVertices, vecPool2:clone())
        table.insert(subdividedVertices, vecPool3:clone())
        table.insert(subdividedVertices, vec3.clone(v1))
        table.insert(subdividedVertices, vecPool1:clone())
        table.insert(subdividedVertices, vecPool3:clone())
        table.insert(subdividedVertices, vec3.clone(v2))
        table.insert(subdividedVertices, vecPool2:clone())
        table.insert(subdividedVertices, vecPool1:clone())
        table.insert(subdividedVertices, vec3.clone(v3))
        table.insert(subdividedVertices, vecPool3:clone())
        table.insert(subdividedVertices, vecPool2:clone())
      end
      self.vertices = subdividedVertices
      -- Move all the new vertices to be on the unit ciircle
      for _, vertex in ipairs(self.vertices) do
        vec3.normalize(vertex, vertex)
      end
    end
    self:cleanUpVertices()
  end
})
Shape.Sphere = Sphere:new(2)

local CubePerson = defineClass(Shape, {
  init = function(self)
    local bodyTopLeft = -1
    local bodyTopRight = 1
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
      vec3(bodyTopLeft,     bodyTop,    bodyFront, 0, 0),
      vec3(bodyTopRight,    bodyTop,    bodyFront, 1, 0),
      vec3(bodyBottomLeft,  bodyBottom, bodyFront, 0, 1),
      vec3(bodyBottomRight, bodyBottom, bodyFront, 1, 1),
      -- Body back face
      vec3(bodyTopRight,    bodyTop,    bodyBack,  0, 0),
      vec3(bodyTopLeft,     bodyTop,    bodyBack,  1, 0),
      vec3(bodyBottomRight, bodyBottom, bodyBack,  0, 1),
      vec3(bodyBottomLeft,  bodyBottom, bodyBack,  1, 1),
      -- Body top face
      vec3(bodyTopLeft,     bodyTop,    bodyBack,  0, 0),
      vec3(bodyTopRight,    bodyTop,    bodyBack,  1, 0),
      vec3(bodyTopLeft,     bodyTop,    bodyFront, 0, 1),
      vec3(bodyTopRight,    bodyTop,    bodyFront, 1, 1),
      -- Body bottom face
      vec3(bodyBottomLeft,  bodyBottom, bodyFront, 0, 0),
      vec3(bodyBottomRight, bodyBottom, bodyFront, 1, 0),
      vec3(bodyBottomLeft,  bodyBottom, bodyBack,  0, 1),
      vec3(bodyBottomRight, bodyBottom, bodyBack,  1, 1),
      -- Body left face
      vec3(bodyTopLeft,     bodyTop,    bodyBack,  0, 0),
      vec3(bodyTopLeft,     bodyTop,    bodyFront, 1, 0),
      vec3(bodyBottomLeft,  bodyBottom, bodyBack,  0, 1),
      vec3(bodyBottomLeft,  bodyBottom, bodyFront, 1, 1),
      -- Body right face
      vec3(bodyTopRight,    bodyTop,    bodyFront, 0, 0),
      vec3(bodyTopRight,    bodyTop,    bodyBack,  1, 0),
      vec3(bodyBottomRight, bodyBottom, bodyFront, 0, 1),
      vec3(bodyBottomRight, bodyBottom, bodyBack,  1, 1),

      -- Head front face
      vec3(headLeft,  headTop,    headFront, 0, 0),
      vec3(headRight, headTop,    headFront, 1, 0),
      vec3(headLeft,  headBottom, headFront, 0, 1),
      vec3(headRight, headBottom, headFront, 1, 1),
      -- Head back face
      vec3(headRight, headTop,    headBack,  0, 0),
      vec3(headLeft,  headTop,    headBack,  1, 0),
      vec3(headRight, headBottom, headBack,  0, 1),
      vec3(headLeft,  headBottom, headBack,  1, 1),
      -- Head top face
      vec3(headLeft,  headTop,    headBack,  0, 0),
      vec3(headRight, headTop,    headBack,  1, 0),
      vec3(headLeft,  headTop,    headFront, 0, 1),
      vec3(headRight, headTop,    headFront, 1, 1),
      -- Head bottom face
      vec3(headLeft,  headBottom, headFront, 0, 0),
      vec3(headRight, headBottom, headFront, 1, 0),
      vec3(headLeft,  headBottom, headBack,  0, 1),
      vec3(headRight, headBottom, headBack,  1, 1),
      -- Head left face
      vec3(headLeft,  headTop,    headBack,  0, 0),
      vec3(headLeft,  headTop,    headFront, 1, 0),
      vec3(headLeft,  headBottom, headBack,  0, 1),
      vec3(headLeft,  headBottom, headFront, 1, 1),
      -- Head right face
      vec3(headRight, headTop,    headFront, 0, 0),
      vec3(headRight, headTop,    headBack,  1, 0),
      vec3(headRight, headBottom, headFront, 0, 1),
      vec3(headRight, headBottom, headBack,  1, 1),

      -- Arm front face
      vec3(armLeft,  armTop,    armFront, 0, 0),
      vec3(armRight, armTop,    armFront, 1, 0),
      vec3(armLeft,  armBottom, armFront, 0, 1),
      vec3(armRight, armBottom, armFront, 1, 1),
      -- Arm back face
      vec3(armRight, armTop,    armBack,  0, 0),
      vec3(armLeft,  armTop,    armBack,  1, 0),
      vec3(armRight, armBottom, armBack,  0, 1),
      vec3(armLeft,  armBottom, armBack,  1, 1),
      -- Arm top face
      vec3(armLeft,  armTop,    armBack,  0, 0),
      vec3(armRight, armTop,    armBack,  1, 0),
      vec3(armLeft,  armTop,    armFront, 0, 1),
      vec3(armRight, armTop,    armFront, 1, 1),
      -- Arm bottom face
      vec3(armLeft,  armBottom, armFront, 0, 0),
      vec3(armRight, armBottom, armFront, 1, 0),
      vec3(armLeft,  armBottom, armBack,  0, 1),
      vec3(armRight, armBottom, armBack,  1, 1),
      -- Arm left face
      vec3(armLeft,  armTop,    armBack,  0, 0),
      vec3(armLeft,  armTop,    armFront, 1, 0),
      vec3(armLeft,  armBottom, armBack,  0, 1),
      vec3(armLeft,  armBottom, armFront, 1, 1),
      -- Arm right face
      vec3(armRight, armTop,    armFront, 0, 0),
      vec3(armRight, armTop,    armBack,  1, 0),
      vec3(armRight, armBottom, armFront, 0, 1),
      vec3(armRight, armBottom, armBack,  1, 1)
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
