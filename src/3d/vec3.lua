-- Writing my own vec3 library because cpml.vec3 actually produces a lot of garbage -_-
local cpml = require('libs/cpml')

local vec3
local sqrt = math.sqrt

local tempMat4 = cpml.mat4()
local tempVec4 = {}

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
    return setmetatable({ v[1], v[2], v[3] }, vec3)
  end,
  zero = function(out)
    out[1], out[2], out[3] = 0, 0, 0
    return out
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
    return sqrt(v[1] * v[1] + v[2] * v[2] + v[3] * v[3])
  end,
  squareLength = function(v)
    return v[1] * v[1] + v[2] * v[2] + v[3] * v[3]
  end,
  normalize = function(out, v)
    if v[1] == 0 and v[2] == 0 and v[3] == 0 then
      out[1], out[2], out[3] = 0, 0, 0
    else
      local len = sqrt(v[1] * v[1] + v[2] * v[2] + v[3] * v[3])
      out[1], out[2], out[3] = v[1] / len, v[2] / len, v[3] / len
    end
    return out
  end,
  cross = function(out, v1, v2)
    out[1], out[2], out[3] = v1[2] * v2[3] - v1[3] * v2[2], v1[3] * v2[1] - v1[1] * v2[3], v1[1] * v2[2] - v1[2] * v2[1]
    return out
  end,
  dot = function(v1, v2)
    return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
  end,
  -- Returns the projection of v1 onto v2
  project = function(out, v1, v2)
    local dot = v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
    local len2 = v2[1] * v2[1] + v2[2] * v2[2] + v2[3] * v2[3]
    out[1], out[2], out[3] = v2[1] * dot / len2, v2[2] * dot / len2, v2[3] * dot / len2
    return out
  end,
  angleBetween = function(v1, v2)
    local dot = v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
    local len1 = sqrt(v1[1] * v1[1] + v1[2] * v1[2] + v1[3] * v1[3])
    local len2 = sqrt(v2[1] * v2[1] + v2[2] * v2[2] + v2[3] * v2[3])
    return math.acos(dot / (len1 * len2))
  end,
  -- Conversion functions
  dirToAngle = function(out, dir, up)
    local angleX, angleY, angleZ
    -- TODO if dir has length zero, do something sensible
    local unitX = vec3(1, 0, 0)
    local unitY = vec3(0, 1, 0)
    local unitZ = vec3(0, 0, 1)
    -- Project the direction onto the XZ plane (left/right/forward/back)
    local dirNormalized = vec3():normalize(dir)
    local dirProjectionXZ = vec3()
    dirProjectionXZ:project(dirNormalized, unitY)
    dirProjectionXZ:subtract(dirNormalized, dirProjectionXZ)
    -- If the projection has length zero, it means we're pointing directly up or down
    if dirProjectionXZ:squareLength() == 0 then
      -- We've rotated upward or downwards the full amount
      angleX = (dirNormalized[2] < 0 and 1 or -1) * math.pi / 2
      -- It's hard to tell how much we've rotated left/right (TODO can we do better?)
      angleY = 0
    else
      -- The angle between the projection and the actual vector is the amount you need to turn up/down
      angleX = vec3.angleBetween(dirProjectionXZ, dirNormalized) * (unitY:dot(dirNormalized) < 0 and 1 or -1)
      -- The angle between the projection and the unit z vector is the amount you need to turn left/right
      local cross = vec3():cross(dirProjectionXZ, unitZ)
      angleY = vec3.angleBetween(dirProjectionXZ, unitZ) * (unitY:dot(cross) < 0 and 1 or -1)
    end
    if up then
      -- Project the unit Y vector onto the plane of the direction
      local projection = vec3()
      projection:project(unitY, dirNormalized)
      projection:subtract(unitY, projection)
      -- The angle between the projected unit Y vector and the up vector is the amount you need to roll clockwise/counter-clockwise
      local cross = vec3():cross(projection, up)
      angleZ = vec3.angleBetween(projection, up) * (cross:dot(dirNormalized) < 0 and -1 or 1)
    else
      -- Without an up vector, it's hard to tell how much to roll (TODO can we do better?)
      angleZ = 0
    end
    out[1], out[2], out[3] = angleX, angleY, angleZ
    -- TODO angleZ
    return out


    -- -- Works half of the time, sometimes the z angle should be negative it seems:
    -- local len = sqrt(dir[1] * dir[1] + dir[2] * dir[2] + dir[3] * dir[3])
    -- local someAngle
    -- if up then
    --   local trueUp = vec3(0, 1, 0)
    --   local projection = vec3():project(trueUp, dir)
    --   trueUp:subtract(trueUp, projection)
    --   local trueUpLen = sqrt(trueUp[1] * trueUp[1] + trueUp[2] * trueUp[2] + trueUp[3] * trueUp[3])
    --   local upLen = sqrt(up[1] * up[1] + up[2] * up[2] + up[3] * up[3])
    --   local dot = up.x * trueUp.x + up.y * trueUp.y + up.z * trueUp.z
    --   someAngle = math.acos(dot / (upLen * trueUpLen))
    -- else
    --   someAngle = 0
    -- end
    -- out[1], out[2], out[3] = -math.asin(dir[2] / len), math.atan2(dir[1] / len, dir[3] / len), -someAngle
    -- return out
  end,
  angleToDir = function(out, angle)
    -- Prepare a transformation matrix
    tempMat4:identity()
    tempMat4:rotate(tempMat4, angle[2], cpml.vec3.unit_y)
    tempMat4:rotate(tempMat4, angle[1], cpml.vec3.unit_x)
    tempMat4:rotate(tempMat4, angle[3], cpml.vec3.unit_z)
    -- Multiply it with a unit vec4
    tempVec4[1], tempVec4[2], tempVec4[3], tempVec4[4] = 0, 0, 1, 1
    cpml.mat4.mul_vec4(tempVec4, tempMat4, tempVec4)
    out[1], out[2], out[3] = tempVec4[1], tempVec4[2], tempVec4[3]
    return out
  end
}

-- Calling vec3() returns a new vector
setmetatable(vec3, {
  __call = function(_, x, y, z, ...)
    return setmetatable({ x or 0, y or 0, z or 0, ... }, vec3)
  end
})

return vec3
