Context = {
}

function Context:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Context:update(grid)
end

function Context:draw(adapter)
end

function Context:mousemoved(x, y, dx, dy, istouch)
end

function Context:mousepressed(x, y, button, istouch, presses)
end

function Context:mousereleased(x, y, button, istouch, presses)
end

function Context:isActive()
    return true
end

function Context:reset()
end

function Context:restartReset()
end
