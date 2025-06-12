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

function Context:draw(grid)
end

function Context:isActive()
    return false
end
