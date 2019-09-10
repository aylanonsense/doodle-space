local defineClass = require('utils/defineClass')
local Controller = require('input/Controller')

local ALL_KEYS = {  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'space', '!', '"', '#', '$', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/', ':', ';', '<', '=', '>', '?', '@', '[', '\\', ']', '^', '_', '`', 'kp0', 'kp1', 'kp2', 'kp3', 'kp4', 'kp5', 'kp6', 'kp7', 'kp8', 'kp9', 'kp.', 'kp,', 'kp/', 'kp*', 'kp-', 'kp+', 'kpenter', 'kp=', 'up', 'down', 'right', 'left', 'home', 'end', 'pageup', 'pagedown', 'insert', 'backspace', 'tab', 'clear', 'return', 'delete', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12', 'f13', 'f14', 'f15', 'f16', 'f17', 'f18', 'numlock', 'capslock', 'scrolllock', 'rshift', 'lshift', 'rctrl', 'lctrl', 'ralt', 'lalt', 'rgui', 'lgui', 'mode', 'www', 'mail', 'calculator', 'computer', 'appsearch', 'apphome', 'appback', 'appforward', 'apprefresh', 'appbookmarks', 'pause', 'escape', 'help', 'printscreen', 'sysreq', 'menu', 'application', 'power', 'currencyunit', 'undo' }

local KeyboardController = defineClass(Controller, {
  update = function(self, dt)
    Controller.update(self, dt)
    -- Check for any buttons that were pressed
    for _, button in ipairs(ALL_KEYS) do
      local buttonState = self._buttons[button]
      if buttonState and not buttonState.isDown and love.keyboard.isDown(button) then
        self:recordPress(button)
      end
    end
    -- Also check for any buttons that were released
    for button, buttonState in pairs(self._buttons) do
      if buttonState.isDown and not love.keyboard.isDown(button) then
        self:recordRelease(button)
      end
    end
  end,
  keypressed = function(self, key, scancode, isRepeat)
    if not isRepeat then
      self:recordPress(key)
    end
  end,
  keyreleased = function(self, key, scancode)
    self:recordRelease(key)
  end
})

return KeyboardController
