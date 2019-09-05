-- Writing my own vec3 library because cpml.vec3 actually produces a lot of garbage -_-
local cpml = require('libs/cpml')

local vec3

-- Object pool
local tempMat = cpml.mat4()
local tempTransformObj = {}
local tempAngleToDirVec, tempAngleBetweenVec, tempProjectOntoPlaneVec
local tempVec1, tempVec2, tempVec3
local unitX, unitY, unitZ

vec3 = {
  __index = function(v, key)
    if key == 'x' then
      return rawget(v, 1)
    elseif key == 'y' then
      return rawget(v, 2)
    elseif key == 'z' then
      return rawget(v, 3)
    elseif rawget(v, key) ~= nil then
      return rawget(v, key)
    else
      return rawget(vec3, key)
    end
  end,
  __newindex = function(v, key, value)
    if key == 'x' then
      rawset(v, 1, value)
    elseif key == 'y' then
      rawset(v, 2, value)
    elseif key == 'z' then
      rawset(v, 3, value)
    else
      rawset(v, key, value)
    end
  end,
  fromArray = function(out)
    return setmetatable(out, vec3)
  end,
  clone = function(v)
    return vec3(v[1], v[2], v[3])
  end,
  zero = function(out)
    out[1], out[2], out[3] = 0, 0, 0
    return out
  end,
  isZero = function(v)
    return v[1] == 0 and v[2] == 0 and v[3] == 0
  end,
  set = function(out, v)
    out[1], out[2], out[3] = v[1], v[2], v[3]
    return out
  end,
  setValues = function(out, x, y, z)
    out[1], out[2], out[3] = x, y, z
    return out
  end,
  add = function(out, v1, v2)
    out[1], out[2], out[3] = v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3]
    return out
  end,
  addValues = function(out, v, x, y, z)
    out[1], out[2], out[3] = v[1] + x, v[2] + y, v[3] + z
    return out
  end,
  subtract = function(out, v1, v2)
    out[1], out[2], out[3] = v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3]
    return out
  end,
  subtractValues = function(out, v, x, y, z)
    out[1], out[2], out[3] = v[1] - x, v[2] - y, v[3] - z
    return out
  end,
  multiply = function(out, v1, v2)
    out[1], out[2], out[3] = v1[1] * v2[1], v1[2] * v2[2], v1[3] * v2[3]
    return out
  end,
  multiplyValues = function(out, v, x, y, z)
    out[1], out[2], out[3] = v[1] * x, v[2] * y, v[3] * z
    return out
  end,
  average = function(out, v1, v2)
    out[1], out[2], out[3] = (v1[1] + v2[1]) / 2, (v1[2] + v2[2]) / 2, (v1[3] + v2[3]) / 2
    return out
  end,
  averageValues = function(out, v, x, y, z)
    out[1], out[2], out[3] = (v[1] + x) / 2, (v[2] + y) / 2, (v[3] + z) / 2
    return out
  end,
  length = function(v)
    return math.sqrt(v[1] * v[1] + v[2] * v[2] + v[3] * v[3])
  end,
  squareLength = function(v)
    return v[1] * v[1] + v[2] * v[2] + v[3] * v[3]
  end,
  normalize = function(out, v)
    if v[1] == 0 and v[2] == 0 and v[3] == 0 then
      out[1], out[2], out[3] = 0, 0, 0
    else
      local len = vec3.length(v)
      out[1], out[2], out[3] = v[1] / len, v[2] / len, v[3] / len
    end
    return out
  end,
  cross = function(out, v1, v2)
    out[1], out[2], out[3] = v1[2] * v2[3] - v1[3] * v2[2], v1[3] * v2[1] - v1[1] * v2[3], v1[1] * v2[2] - v1[2] * v2[1]
    return out
  end,
  crossValues = function(out, v, x, y, z)
    out[1], out[2], out[3] = v[2] * z - v[3] * y, v[3] * x - v[1] * z, v[1] * y - v[2] * x
    return out
  end,
  dot = function(v1, v2)
    return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
  end,
  -- Returns the projection of v1 onto v2
  project = function(out, v1, v2)
    local dot = vec3.dot(v1, v2)
    local len2 = vec3.squareLength(v2)
    out[1], out[2], out[3] = v2[1] * dot / len2, v2[2] * dot / len2, v2[3] * dot / len2
    return out
  end,
  projectOntoPlane = function(out, v1, normal)
    tempProjectOntoPlaneVec:project(v1, normal)
    tempProjectOntoPlaneVec:subtract(v1, tempProjectOntoPlaneVec)
    out[1], out[2], out[3] = tempProjectOntoPlaneVec[1], tempProjectOntoPlaneVec[2], tempProjectOntoPlaneVec[3]
    return out
  end,
  angleBetween = function(v1, v2, positiveVector)
    local dot = vec3.dot(v1, v2)
    local len1 = vec3.length(v1)
    local len2 = vec3.length(v2)
    local angle = math.acos(dot / (len1 * len2))
    -- If the acos is NaN or infiniity, it means there's 0 angle between them
    if angle ~= angle then
      return 0
    -- Figure out if the angle should be positive or negative
    elseif positiveVector then
      tempAngleBetweenVec:cross(v1, v2)
      return angle * (tempAngleBetweenVec:dot(positiveVector) > 0 and 1 or -1)
    else
      return angle
    end
  end,
  -- Conversion functions
  dirToAngle = function(out, dir, up)
    -- If the vector is length zero, there isn't much we can do
    if vec3.isZero(dir) then
      out[1], out[2], out[3] = 0, 0, 0
    else
      local angleX, angleY, angleZ
      -- Project the vector onto the XZ plane (left/right)
      local dirNormalized = tempVec1:normalize(dir)
      local dirProjectionXZ = tempVec2:project(dirNormalized, unitY)
      dirProjectionXZ:subtract(dirNormalized, dirProjectionXZ)
      -- If the projection has length zero, it means we're pointing directly up or down
      if dirProjectionXZ:isZero() then
        -- We've rotated upward or downwards the full amount
        angleX = (dirNormalized[2] < 0 and 1 or -1) * math.pi / 2
        -- It's hard to tell how much we've rotated left/right (TODO can we do better?)
        angleY = 0
        -- It's also hard to tell how much we've rolled clockwise/counter-clockwise
        angleZ = 0
      else
        -- The angle between the projection and the actual vector is the amount you need to turn up/down
        angleX = vec3.angleBetween(dirProjectionXZ, dirNormalized) * (unitY:dot(dirNormalized) < 0 and 1 or -1)
        -- The angle between the projection and the unit z vector is the amount you need to turn left/right
        local cross = tempVec3:cross(dirProjectionXZ, unitZ)
        angleY = dirProjectionXZ:angleBetween(unitZ) * (cross:dot(unitY) < 0 and 1 or -1)
        if up then
          -- TODO handle pointing directly up/down?
          -- Project the unit Y vector onto the plane of the vector
          local unitYProjectDir = tempVec2:project(unitY, dirNormalized)
          unitYProjectDir:subtract(unitY, unitYProjectDir)
          -- The angle between the projected unit Y vector and the up vector is the amount you need to roll clockwise/counter-clockwise
          local cross = tempVec3:cross(unitYProjectDir, up)
          angleZ = unitYProjectDir:angleBetween(up) * (cross:dot(dirNormalized) < 0 and -1 or 1)
        else
          -- Without an up vector, it's hard to tell how much to roll (TODO can we do better?)
          angleZ = 0
        end
      end
      out[1], out[2], out[3] = angleX, angleY, angleZ
    end
    return out
  end,
  angleToDir = function(out, angle)
    -- Prepare a transformation matrix
    local transform = tempMat:identity()
    transform:rotate(transform, angle[2], cpml.vec3.unit_y)
    transform:rotate(transform, angle[1], cpml.vec3.unit_x)
    transform:rotate(transform, angle[3], cpml.vec3.unit_z)
    -- Multiply it by a unit vector
    tempAngleToDirVec:setValues(0, 0, 1)
    return vec3.applyTransform(out, tempAngleToDirVec, transform)
  end,
  applyTransform = function(out, v, transform)
    local vec4 = tempTransformObj
    vec4[1], vec4[2], vec4[3], vec4[4] = v[1], v[2], v[3], 1
    cpml.mat4.mul_vec4(vec4, transform, vec4)
    out[1], out[2], out[3] = vec4[1], vec4[2], vec4[3]
    return out
  end
}

-- Calling vec3() returns a new vector
setmetatable(vec3, {
  __call = function(_, x, y, z, ...)
    return setmetatable({ x or 0, y or 0, z or 0, ... }, vec3)
  end
})

-- Initialize object pool
unitX, unitY, unitZ = vec3(1, 0, 0), vec3(0, 1, 0), vec3(0, 0, 1)
tempAngleToDirVec, tempAngleBetweenVec, tempProjectOntoPlaneVec = vec3(), vec3(), vec3()
tempVec1, tempVec2, tempVec3 = vec3(), vec3(), vec3()

return vec3
