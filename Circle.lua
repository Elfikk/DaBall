require("PositionVector")

Circle = {
    radius = 1,
    position = PositionVector:new(0, 0),
    hitpoints = 1 -- This never changes
}

function Circle:new(x, y, r)
    -- Create a new ball object
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.radius = r
    o.position = PositionVector:new(x, y)
    return o
end

function Circle:inside(otherPos)
    local diffPos = self.position - otherPos
    local diffSq = diffPos:dot(diffPos)
    local isInside = diffSq < self.radius * self.radius
    if isInside then
        self.hitpoints = self.hitpoints - 1
    end
    return isInside
end

function Circle:getPos()
    return self.position
end

function Circle:getRadius()
    return self.radius
end

function Circle:moveDown(delta_y)
    self.position = self.position + PositionVector:new(0, delta_y)
end

function Circle:isValid()
    return self.hitpoints ~= 0
end
