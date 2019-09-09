local defineClass = require('utils/defineClass')

local ObjectPool = defineClass({
  objectClass = nil,
  isCallableObjectClass = false,
  keyedPool = nil,
  available = nil,
  init = function(self, objectClass, isCallable)
    self.objectClass = objectClass
    self.isCallableObjectClass = isCallable or false
    self.keyedPool = {}
    self.available = {}
  end,
  withdraw = function(self, key)
    if key then
      if not self.keyedPool[key] then
        self.keyedPool[key] = self:_createNewObject()
      end
      return self.keyedPool[key]
    elseif #self.available > 0 then
      local obj = self.available[#self.available]
      table.remove(self.available, #self.available)
      return obj
    else
      return self:_createNewObject()
    end
  end,
  release = function(self, obj)
    table.insert(self.available, obj)
  end,
  _createNewObject = function(self)
    if self.objectClass then
      if self.isCallableObjectClass then
        return self.objectClass()
      else
        return self.objectClass:new()
      end
    else
      return {}
    end
  end
})

return ObjectPool
