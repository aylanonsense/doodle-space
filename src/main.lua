local Game = require('game/Game')
local controllers = require('input/controllers')

-- Game variables
local game

function love.load()
  -- Set some graphics values
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setBackgroundColor(0.92, 0.57, 0.69)

  -- Create a controller
  local controller = controllers:newController()
  controllers.keyboard:pipe(controller, {
    buttons = {
      toggleEditMode = { 'tab' },
      sprint = { 'lshift' },
      moveUp = { 'space' },
      moveDown = { 'lctrl'}
    },
    joysticks = {
      move = {
        up = { 'w', 'up' },
        left = { 'a', 'left' },
        down = { 's', 'down' },
        right = { 'd', 'right' }
      }
    }
  })
  controllers.mouse:pipe(controller, {
    buttons = {
      createDebugArrow = { 'mouse-btn-1' }
    },
    joysticks = {
      look = 'mouse-move'
    }
  })

  -- Create the game
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  game = Game:new(controller, width, height)
end

function love.update(dt)
  controllers:update(dt)
  game:update(dt)
  controllers:postUpdate(dt)
end

function love.draw()
  game:draw()
end

function love.resize(width, height)
  game:resize(width, height)
end
