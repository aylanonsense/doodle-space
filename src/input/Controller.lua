local defineClass = require('utils/defineClass')

local Controller = defineClass({
  _buttons = nil,
  _joysticks = nil,
  _connections = nil,
  init = function(self)
    self.a = math.random()
    self._buttons = {}
    self._joysticks = {}
    self._connections = {}
  end,
  update = function(self, dt)
    -- Record the state for all button-based joysticks
    for _, connection in ipairs(self._connections) do
      local controller, mapping = connection.controller, connection.mapping
      if mapping.joysticks then
        for targetJoystick, sourceJoystick in pairs(mapping.joysticks) do
          if sourceJoystick.up or sourceJoystick.left or sourceJoystick.down or sourceJoystick.right then
            -- We've found a button-based joystick
            local up, left, down, right = 0, 0, 0, 0
            local joystickDirections = {
              up = 0,
              left = 0,
              down = 0,
              right = 0
            }
            for dir, _ in pairs(joystickDirections) do
              for _, sourceButton in ipairs(sourceJoystick[dir]) do
                if self:isDown(sourceButton) then
                  joystickDirections[dir] = 1
                end
              end
            end
            local x = joystickDirections.right - joystickDirections.left
            local y = joystickDirections.down - joystickDirections.up
            if x ~= 0 and y ~= 0 then
              x = x * math.sqrt(2) / 2
              y = y * math.sqrt(2) / 2
            end
            controller:recordJoystick(targetJoystick, x, y, true)
          end
        end
      end
    end
  end,
  postUpdate = function(self, dt)
    -- Increment all button states
    for _, buttonState in pairs(self._buttons) do
      if buttonState.press then
        buttonState.press = buttonState.press + 1
      end
      if buttonState.release then
        buttonState.release = buttonState.release + 1
      end
    end
    -- Increment all joystick states
    for _, joystickState in pairs(self._joysticks) do
      if joystickState.move then
        joystickState.move = joystickState.move + 1
      end
    end
  end,
  recordButton = function(self, button, isDown)
    if not self._buttons[button] then
      self._buttons[button] = {}
    end
    -- Update the isDown state of the button
    local wasDown = self._buttons[button].isDown
    self._buttons[button].isDown = isDown
    -- This may effectively cause the button to become "pressed" or "released"
    if not wasDown and isDown then
      self._buttons[button].press = 0
      self:_pipePress(button)
    elseif wasDown and not isDown then
      self._buttons[button].release = 0
      self:_pipeRelease(button)
    end
  end,
  recordPress = function(self, button)
    if not self._buttons[button] then
      self._buttons[button] = {}
    end
    -- Record the button press
    self._buttons[button].press = 0
    self._buttons[button].isDown = true
    -- Tell connected controllers
    self:_pipePress(button)
  end,
  recordRelease = function(self, button)
    if not self._buttons[button] then
      self._buttons[button] = {}
    end
    -- Record the button release
    self._buttons[button].release = 0
    self._buttons[button].isDown = false
    -- Tell connected controllers
    self:_pipeRelease(button)
  end,
  -- Return true if the button is held down
  isDown = function(self, button)
    if self._buttons[button] then
      return self._buttons[button].isDown
    else
      return false
    end
  end,
  -- Return true if the button was pressed recently
  justPressed = function(self, button, buffer, consume)
    local buttonState = self._buttons[button]
    if buttonState and buttonState.press and buttonState.press <= (buffer or 0) then
      -- Consume the button press in the process
      if consume then
        buttonState.press = nil
      end
      return true
    else
      return false
    end
  end,
  -- Return true if the button was released recently
  justReleased = function(self, button, buffer, consume)
    local buttonState = self._buttons[button]
    if buttonState and buttonState.release and buttonState.release <= (buffer or 0) then
      -- Consume the button release in the process
      if consume then
        buttonState.release = nil
      end
      return true
    else
      return false
    end
  end,
  consumePress = function(self, button)
    if self._buttons[button] then
      self._buttons[button].press = nil
    end
  end,
  consumeRelease = function(self, button)
    if self._buttons[button] then
      self._buttons[button].release = nil
    end
  end,
  recordJoystick = function(self, joystick, x, y, countsAsMove)
    countsAsMove = countsAsMove ~= false
    if not self._joysticks[joystick] then
      self._joysticks[joystick] = { move = 0 }
    end
    local joystickState = self._joysticks[joystick]
    if joystickState.x ~= x or joystickState.y ~= y then
      joystickState.x = x
      joystickState.y = y
      if countsAsMove then
        joystickState.move = 0
      end
      self:_pipeJoystick(joystick, x, y, countsAsMove)
    end
  end,
  getJoystick = function(self, joystick)
    if self._joysticks[joystick] then
      return self._joysticks[joystick].x or 0, self._joysticks[joystick].y or 0
    else
      return 0, 0
    end
  end,
  justMovedJoystick = function(self, joystick, buffer, consume)
    local joystickState = self._joysticks[joystick]
    if joystickState and joystickState.move and joystickState.move <= (buffer or 0) then
      -- Consume the joystick move in the process
      if consume then
        joystickState.move = nil
      end
      return true
    else
      return false
    end
  end,
  map = function(self, controllers, mapping)
    --[[
      Example mapping:

        {
          buttons = {
            jump = { 'space' }
            shoot = { 'z', 'x' }
            accept = { 'z' }
            cancel = { 'x' }
          }
          joysticks = {
            aim = 'leftjoystick'
          }
        }
    ]]
    -- TODO allow for joytick -> button and button -> joystick mappings
    for _, controller in ipairs(controllers) do
      controller:pipe(self, mapping)
    end
  end,
  pipe = function(self, controller, mapping)
    table.insert(self._connections, { controller = controller, mapping = mapping })
  end,
  unpipe = function(self, controller)
    for i = #self._connections, 1, -1 do
      if self._connections[i].controller == controller then
        table.remove(self._connections, i)
      end
    end
  end,
  _pipePress = function(self, button)
    for _, connection in ipairs(self._connections) do
      local controller, mapping = connection.controller, connection.mapping
      if not mapping then
        controller:recordPress(button)
      elseif mapping.buttons then
        for targetButton, sourceButtons in pairs(mapping.buttons) do
          for _, sourceButton in ipairs(sourceButtons) do
            if sourceButton == button then
              controller:recordPress(targetButton)
            end
          end
        end
      end
    end
  end,
  _pipeRelease = function(self, button)
    for _, connection in ipairs(self._connections) do
      local controller, mapping = connection.controller, connection.mapping
      if not mapping then
        controller:recordRelease(button)
      elseif mapping.buttons then
        for targetButton, sourceButtons in pairs(mapping.buttons) do
          for _, sourceButton in ipairs(sourceButtons) do
            if sourceButton == button then
              controller:recordRelease(targetButton)
            end
          end
        end
      end
    end
  end,
  _pipeJoystick = function(self, joystick, x, y, countsAsMove)
    for _, connection in ipairs(self._connections) do
      local controller, mapping = connection.controller, connection.mapping
      if not mapping then
        controller:recordJoystick(joystick, x, y)
      elseif mapping.joysticks then
        for targetJoystick, sourceJoystick in pairs(mapping.joysticks) do
          if sourceJoystick == joystick then
            controller:recordJoystick(targetJoystick, x, y, countsAsMove)
          end
        end
      end
    end
  end
})

return Controller
