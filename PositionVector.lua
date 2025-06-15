PositionVector = {
    x = 0,
    y = 0
}

function PositionVector:new (x, y)
    local o = {x = x, y = y}
    setmetatable(o, self)
    self.__index = self
    return o
end

function PositionVector:__add(other)
    return PositionVector:new(self.x + other.x, self.y + other.y)
end

function PositionVector:__sub(other)
    return PositionVector:new(self.x - other.x, self.y - other.y)
end

function PositionVector:__div(scale)
    return PositionVector:new(self.x / scale, self.y / scale)
end

function PositionVector:dot(other)
    return self.x * other.x + self.y * other.y
end

function PositionVector:cross(other)
    return self.x * other.y - other.x * self.y
end
