local sqrt = math.sqrt

local function new(x, y, z)
  return { x or 0, y or 0, z or 0 }
end

local function clone(out, v)
  out[1], out[2], out[3] = v[1], v[2], v[3]
  return out
end

local function normalize(out, v)
  if v[1] == 0 and v[2] == 0 and v[3] == 0 then
    out[1], out[2], out[3] = 0, 0, 0
  else
    local len = sqrt(v[1] * v[1] + v[2] * v[2] + v[3] * v[3])
    out[1], out[2], out[3] = v[1] / len, v[2] / len, v[3] / len
  end
  return out
end

return {
  new = new,
  clone = clone,
  normalize = normalize
}
