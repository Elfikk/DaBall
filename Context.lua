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

function Context:mousemoved()
end

function Context:mousepressed()
end

function Context:mousereleased()
end

function Context:isActive()
    return false
end
