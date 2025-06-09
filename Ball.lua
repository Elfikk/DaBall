require("PositionVector")

Ball = {
    posLast = PositionVector:new(0, 0),
    posNow = PositionVector:new(0, 0),
    velNow = PositionVector:new(0, 0),
    id = 0
}

function Ball:new (posNow, velNow)
    -- Create a new ball object
    local o = {}
    Ball.id = Ball.id + 1
    setmetatable(o, self)
    self.__index = self
    o.posLast = posNow
    o.posNow = posNow
    o.velNow = velNow
    o.id = Ball.id
    return o
end

function Ball:getPos() -- Colon operator hides implicit self
    return self.posNow
end

function Ball:getPosLast()
    return self.posLast
end

function Ball:getVel()
    return self.velNow
end

function Ball:setPos(x, y)
    self.posLast = self.posNow
    self.posNow = PositionVector:new(x, y)
end

function Ball:setVel(vx, vy)
    self.velNow = PositionVector:new(vx, vy)
end

function Ball:getId()
    return self.id
end
