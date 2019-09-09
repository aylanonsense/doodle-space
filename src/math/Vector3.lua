-- Writing my own vector module because cpml.vec3 actually produces a lot of garbage -_-
local defineClass = require('utils/defineClass')
local ObjectPool = require('utils/ObjectPool')
local cpml = require('libs/cpml')

-- Object pool
local vector3Pool
local objectPool
local transformMatrix

-- Helper method
local function extractVectorValues(x, y, z)
  if not z then
    return x.x or x[1], x.y or x[2], x.z or x[3]
  else
    return x, y, z
  end
end

local Vector3
Vector3 = defineClass({
  metatable = {
    __index = function(self, key)
      if key == 'x' then
        return rawget(self, 1)
      elseif key == 'y' then
        return rawget(self, 2)
      elseif key == 'z' then
        return rawget(self, 3)
      elseif rawget(self, key) ~= nil then
        return rawget(self, key)
      else
        return rawget(Vector3, key)
      end
    end,
    __newindex = function(self, key, value)
      if key == 'x' then
        rawset(self, 1, value)
      elseif key == 'y' then
        rawset(self, 2, value)
      elseif key == 'z' then
        rawset(self, 3, value)
      else
        rawset(self, key, value)
      end
    end,
  },
  init = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = x, y, z
  end,
  clone = function(self)
    return Vector3:new(self.x, self.y, self.z)
  end,
  zero = function(self)
    self.x, self.y, self.z = 0, 0, 0
    return self
  end,
  isZero = function(self)
    return self.x == 0 and self.y == 0 and self.z == 0
  end,
  set = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = 0, 0, 0
    return self
  end,
  add = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = self.x + x, self.y + y, self.z + z
    return self
  end,
  subtract = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = self.x - x, self.y - y, self.z - z
    return self
  end,
  subtractReverse = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = x - self.x, y - self.y, z - self.z
    return self
  end,
  multiply = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = self.x * x, self.y * y, self.z * z
    return self
  end,
  divide = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = self.x / x, self.y / y, self.z / z
    return self
  end,
  divideReverse = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = x / self.x, y / self.y, z / self.z
    return self
  end,
  length = function(self)
    return math.sqrt(self:squareLength())
  end,
  squareLength = function(self)
    return self.x * self.x + self.y * self.y + self.z * self.z
  end,
  normalize = function(self)
    if self:isZero() then
      self:set(0, 0, 0)
    else
      local length = self:length()
      self:divide(length, length, length)
    end
    return self
  end,
  cross = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = self.y * z - self.z * y, self.z * x - self.x * z, self.x * y - self.y * x
    return self
  end,
  crossReverse = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    self.x, self.y, self.z = y * self.z - z * self.y, z * self.x - x * self.z, x * self.y - y * self.x
    return self
  end,
  dot = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    return self.x * x + self.y * y + self.z * z
  end,
  project = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    local mult = self:dot(x, y, z) / (x * x + y * y + z * z)
    self.x, self.y, self.z = x * mult, y * mult, z * mult
    return self
  end,
  projectReverse = function(self, x, y, z)
    x, y, z = extractVectorValues(x, y, z)
    local mult = self:dot(x, y, z) / (self.x * self.x + self.y * self.y + self.z * self.z)
    self.x, self.y, self.z = self.x * mult, self.y * mult, self.z * mult
    return self
  end,
  projectOntoPlane = function(self, normalX, normalY, normalZ)
    normalX, normalY, normalZ = extractVectorValues(normalX, normalY, normalZ)
    local proj = vector3Pool:withdraw('projectOntoPlane-proj')
    proj:set(self):project(normalX, normalY, normalZ)
    self:subtract(proj)
    return self
  end,
  angleBetween = function(self, x, y, z, positiveX, positiveY, positiveZ)
    -- 6 arguments: x, y, z, positiveX, positiveY, positiveZ
    if positiveZ then
      -- do nothing
    -- 4 arguments: either x, y, z, Vector3 ~or~ Vector3, x, y, z
    elseif positiveX then
      if type(x) == 'number' then
        positiveX, positiveY, positiveZ = extractVectorValues(positiveX)
      else
        positiveX, positiveY, positiveZ = y, z, positiveX
        x, y, z = extractVectorValues(x)
      end
    -- 3 arguments: x, y, z
    elseif z then
      -- do nothing
    -- 2 arguments: Vector3, Vector3
    elseif y and not z then
      positiveX, positiveY, positiveZ = extractVectorValues(y)
      x, y, z = extractVectorValues(x)
    -- 1 argument: Vector3
    elseif x then
      x, y, z = extractVectorValues(x)
    end
    -- Okay, let's actually get the angle now
    local vec = vector3Pool:withdraw('angleBetween-vec')
    vec:set(x, y, z)
    local dot = self:dot(vec)
    local angle = math.acos(dot / (self:length() * vec:length()))
    -- If the acos is NaN or infiniity, it means there's either 0 or 180 degrees between them
    if angle ~= angle then
      return (dot > 0) and 0 or math.pi
    -- Figure out if the angle should be positive or negative
    elseif positiveZ then
      local normal = vector3Pool:widthdraw('angleBetween-normal')
      normal:set(self):cross(vec)
      return angle * ((normal:dot(positiveX, positiveY, positiveZ) > 0) and 1 or -1)
    -- We don't have any frame of reference to tell which way is positive so just return the raw angle
    else
      return angle
    end
    return self
  end,
  applyTransform = function(self, transform)
    local obj = objectPool:withdraw('applyTransform')
    obj[1], obj[2], obj[3], obj[4] = self.x, self.y, self.z, 1
    cpml.mat4.mul_obj(obj, transform, obj)
    self.x, self.y, self.z = obj[1], obj[2], obj[3]
    return self
  end,
  -- Converts this vector from representing a direction to a rotation
  toRotation = function(self, upX, upY, upZ)
    upX, upY, upZ = extractVectorValues(upX, upY, upZ)
    -- If the vector is length zero, there isn't much we can do
    if self:isZero() then
      return self
    else
      local rotX, rotY, rotZ
      -- Project the vector onto the XZ plane (left/right)
      self:normalize()
      local projXZ = vector3Pool:withdraw('toRotation-projXZ')
      projXZ:set(self):projectOntoPlane(Vector3.unitY)
      -- If the projection has length zero, it means we're pointing directly up or down
      if projXZ:isZero() then
        rotX, rotY, rotZ = (self.y < 0 and 1 or -1) * math.pi / 2, 0, 0
      else
        -- The angle between the projection and the actual vector is the amount you need to turn up/down
        rotX = projXZ:angleBetween(self) * (self:dot(Vector3.unitY) < 0 and 1 or -1)
        -- The angle between the projection and the unit z vector is the amount you need to turn left/right
        rotY = projXZ:angleBetween(Vector3.unitZ, Vector3.unitY)
        if upX and upY and upZ then
          -- The angle between the projected unit Y vector and the up vector is the amount you need to roll clockwise/counter-clockwise
          local projUnitY = vector3Pool:withdraw('toRotation-projUnitY')
          projUnitY:set(Vector3.unitY):projectOntoPlane(self)
          local exactUp = vector3Pool:withdraw('toRotation-exactUp')
          exactUp:set(upX, upY, upZ):projectOntoPlane(self)
          rotZ = exactUp:angleBetween(projUnitY, self) 
        else
          -- Without an up vector, it's impossible to tell how much to roll
          rotZ = 0
        end
      end
      self.x, self.y, self.z = rotX, rotY, rotZ
    end
    return self
  end,
  -- Converts this vector from representing a rotation to a direction
  toDirection = function(self)
    -- Prepare a transformation matrix
    local transform = transformMatrix:identity()
    transform:rotate(transform, self.y, cpml.vec3.unit_y)
    transform:rotate(transform, self.x, cpml.vec3.unit_x)
    transform:rotate(transform, self.z, cpml.vec3.unit_z)
    -- Multiply it by a unit vector
    return self:set(0, 0, 1):applyTransform(transform)
  end
})

-- Create ynit vectors
Vector3.unitX, Vector3.unitY, Vector3.unitZ = Vector3:new(1, 0, 0), Vector3:new(0, 1, 0), Vector3:new(0, 0, 1)

-- Create object pool
vector3Pool = ObjectPool:new(Vector3)
objectPool = ObjectPool:new(Vector3)
transformMatrix = cpml.mat4()

return Vector3
