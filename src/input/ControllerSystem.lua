local defineClass = require('utils/defineClass')
local Controller = require('input/Controller')
local KeyboardController = require('input/KeyboardController')

local ControllerSystem = defineClass({
  keyboard = nil,
  controllers = nil,
  init = function(self)
    self.keyboard = KeyboardController:new()
    self.controllers = { self.keyboard }
  end,
  update = function(self, dt)
    for _, controller in ipairs(self.controllers) do
      controller:update(dt)
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
  end
})

return ControllerSystem
