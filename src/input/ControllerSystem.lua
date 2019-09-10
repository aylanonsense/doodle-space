local defineClass = require('utils/defineClass')
local Controller = require('input/Controller')
local KeyboardController = require('input/KeyboardController')
local MouseController = require('input/MouseController')

local ControllerSystem = defineClass({
  keyboard = nil,
  mouse = nil,
  controllers = nil,
  init = function(self)
    self.keyboard = KeyboardController:new()
    self.mouse = MouseController:new()
    self.controllers = { self.keyboard, self.mouse }
  end,
  update = function(self, dt)
    for _, controller in ipairs(self.controllers) do
      controller:update(dt)
    end
  end,
  postUpdate = function(self, dt)
    for _, controller in ipairs(self.controllers) do
      controller:postUpdate(dt)
    end
  end,
  newController = function(self, ...)
    local controller = Controller:new(...)
    table.insert(self.controllers, controller)
    return controller
  end,
  keypressed = function(self, ...)
    self.keyboard:keypressed(...)
  end,
  keyreleased = function(self, ...)
    self.keyboard:keyreleased(...)
  end,
  mousepressed = function(self, ...)
    self.mouse:mousepressed(...)
  end,
  mousereleased = function(self, ...)
    self.mouse:mousereleased(...)
  end,
  mousemoved = function(self, ...)
    self.mouse:mousemoved(...)
  end,
  wheelmoved = function(self, ...)
    self.mouse:wheelmoved(...)
  end
})

return ControllerSystem
