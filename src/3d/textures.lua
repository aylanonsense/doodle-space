local function createColoredTexture(r, g, b, a)
  local texture = love.graphics.newCanvas(1, 1)
  love.graphics.setCanvas(texture)
  love.graphics.clear(r, g, b, a or 1)
  love.graphics.setCanvas()
  return texture
end

return {
  black = createColoredTexture(0, 0, 0),
  grey = createColoredTexture(0.5, 0.5, 0.5),
  red = createColoredTexture(1, 0, 0),
  blue = createColoredTexture(0, 0, 1),
  green = createColoredTexture(0, 1, 0)
}
