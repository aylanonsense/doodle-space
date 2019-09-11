local defineClass = require('utils/defineClass')
local Entity = require('game/entity/Entity')
local Shape = require('scene/Shape')
local textures = require('scene/textures')
local Vector3 = require('math/Vector3')

local Player = defineClass(Entity, {
  mass = math.pi * 4 / 3,
  radius = 1,
  gravity = nil,
  init = function(self)
    Entity.init(self, self.game.scene:spawnModel(Shape.CubePerson, textures.yellow))
    self.gravity = Vector3:new()
  end,
  update = function(self, dt)
    -- Sum gravity from nearby planets
    self.gravity:zero()
    for _, planet in ipairs(self.game.groups.planets) do
      local diff = planet:getWorldPosition():clone():subtract(self:getWorldPosition())
      local dist = diff:length()
      local distFromSurface = math.max(0, dist - self.radius - planet.radius)
      local acc = 20 * (self.mass * planet.mass) / math.pow(math.max(distFromSurface, 7), 3)
      diff:multiply(acc * dt, acc * dt, acc * dt)
      self.gravity:add(diff)
    end

    -- Apply gravity
    self.velocity:add(self.gravity)
    self:setAxis(-self.gravity.x, -self.gravity.y, -self.gravity.z, self.zAxis)

    -- Apply velocity
    self.position:add(self.velocity.x * dt, self.velocity.y * dt, self.velocity.z * dt)

    -- Move out of planets
    for _, planet in ipairs(self.game.groups.planets) do
      local diff = planet:getWorldPosition():clone():subtract(self:getWorldPosition())
      local dist = diff:length()
      if dist < self.radius + planet.radius then
        -- Move the player out of the planet
        diff:setLength(self.radius + planet.radius - dist):multiply(-1, -1, -1)
        self.position:add(diff)
        -- Bounce the velocity
        local normal = diff:normalize()
        local planarVel = self.velocity:clone():projectOntoPlane(normal)
        planarVel:subtract(self.velocity):multiply(2, 2, 2):multiply(0.9, 0.9, 0.9)
        self.velocity:add(planarVel):multiply(0.95, 0.95, 0.95)
      end
    end

    -- Apply some friction
    self.velocity:multiply(0.99, 0.99, 0.99)
  end
})

return Player
