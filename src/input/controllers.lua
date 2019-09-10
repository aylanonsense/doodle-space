local ControllerSystem = require('input/ControllerSystem')

-- Create a singleton
local controllers = ControllerSystem:new()

-- Bind love methods
function love.keypressed(...)
  controllers:keypressed(...)
end
function love.keyreleased(...)
  controllers:keyreleased(...)
end
function love.mousepressed(...)
  controllers:mousepressed(...)
end
function love.mousereleased(...)
  controllers:mousereleased(...)
end
function love.mousemoved(...)
  controllers:mousemoved(...)
end
function love.wheelmoved(...)
  controllers:wheelmoved(...)
end

-- Return the singleton
return controllers
