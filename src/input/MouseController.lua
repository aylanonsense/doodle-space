local defineClass = require('utils/defineClass')
local Controller = require('input/Controller')

local MouseController = defineClass(Controller, {
  update = function(self, dt)
    Controller.update(self, dt)

    -- Also check for any mouse buttons that were released
    for button, buttonState in pairs(self._buttons) do
      local btn = button:sub(11)
      if buttonState.isDown and not love.keyboard.isDown(btn) then
        self:recordRelease(button)
      end
    end
  end,
  postUpdate = function(self, dt)
    Controller.postUpdate(self, dt)

    -- Reset joysticks back to 0, 0
    self:recordJoystick('mouse-move', 0, 0, false)
  end,
  mousepressed = function(self, x, y, button)
    self:recordPress('mouse-btn-' .. button)
  end,
  mousereleased = function(self, x, y, button)
    self:recordRelease('mouse-btn-' .. button)
  end,
  mousemoved = function(self, x, y, dx, dy)
    self:recordJoystick('mouse-move', dx, dy)
  end,
  wheelmoved = function(self, x, y) end
})

return MouseController
