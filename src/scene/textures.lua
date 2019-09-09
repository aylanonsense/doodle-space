local function createColoredTexture(r, g, b, a)
  local texture = love.graphics.newCanvas(1, 1)
  love.graphics.push()
  love.graphics.setCanvas(texture)
  love.graphics.clear(r, g, b, a or 1)
  love.graphics.setCanvas()
  love.graphics.pop()
  return texture
end

return {
  black = createColoredTexture(0, 0, 0),
  grey = createColoredTexture(0.5, 0.5, 0.5),
  white = createColoredTexture(1, 1, 1),
  red = createColoredTexture(1, 0, 0),
  green = createColoredTexture(0, 1, 0),
  blue = createColoredTexture(0, 0, 1),
  yellow = createColoredTexture(1, 1, 0),
  magenta = createColoredTexture(1, 0, 1),
  teal = createColoredTexture(0, 1, 1)
}
