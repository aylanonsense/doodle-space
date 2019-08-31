-- Writing my own vec3 library because cpml actually produces a lot of garbage -_-
local vec3
local sqrt = math.sqrt

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
  set = function(out, x, y, z)
    out[1], out[2], out[3] = x, y, z
    return out
  end,
  setVec3 = function(out, v)
    out[1], out[2], out[3] = v[1], v[2], v[3]
    return out
  end,
  add = function(out, v, x, y, z)
    out[1], out[2], out[3] = v[1] + x, v[2] + y, v[3] + z
    return out
  end,
  addVec3 = function(out, v1, v2)
    out[1], out[2], out[3] = v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3]
    return out
  end,
  subtract = function(out, v, x, y, z)
    out[1], out[2], out[3] = v[1] - x, v[2] - y, v[3] - z
    return out
  end,
  subtractVec3 = function(out, v1, v2)
    out[1], out[2], out[3] = v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3]
    return out
  end,
  average = function(out, v, x, y, z)
    out[1], out[2], out[3] = (v[1] + x) / 2, (v[2] + y) / 2, (v[3] + z) / 2
    return out
  end,
  averageVec3 = function(out, v1, v2)
    out[1], out[2], out[3] = (v1[1] + v2[1]) / 2, (v1[2] + v2[2]) / 2, (v1[3] + v2[3]) / 2
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
  end
}

-- Calling vec3() returns a new vector
setmetatable(vec3, {
  __call = function(_, x, y, z, ...)
    return setmetatable({ x or 0, y or 0, z or 0, ... }, vec3)
  end
})

return vec3
