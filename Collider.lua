require("PositionVector")

Collider = {}

CollisionSurface = {
    TOP = {},
    RIGHT = {},
    BOTTOM = {},
    LEFT = {}
}

PossibleCollisions = {
    TOP_LEFT = {negative = CollisionSurface.LEFT, positive = CollisionSurface.TOP},
    TOP_RIGHT = {negative = CollisionSurface.TOP, positive = CollisionSurface.RIGHT},
    BOTTOM_RIGHT = {negative = CollisionSurface.RIGHT, positive = CollisionSurface.BOTTOM},
    BOTTOM_LEFT = {negative = CollisionSurface.BOTTOM, positive = CollisionSurface.LEFT}
}

function Collider:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Collider:handleCollision(ball, box)
    local colSurface = self:collisionSurface(ball, box)

    local bounds = box:getBounds()
    local ballVelocity = ball:getVel()
    local currentPos = ball:getPos()

    if colSurface == CollisionSurface.TOP then
        ball:setPos(currentPos.x, bounds.y1 + (bounds.y1 - currentPos.y))
        ball:setVel(ballVelocity.x, -ballVelocity.y)
    elseif colSurface == CollisionSurface.RIGHT then
        ball:setPos(bounds.x1 + (bounds.x1 - currentPos.x), currentPos.y)
        ball:setVel(-ballVelocity.x, ballVelocity.y)
    elseif colSurface == CollisionSurface.BOTTOM then
        ball:setPos(currentPos.x, bounds.y0 - (currentPos.y - bounds.y0))
        ball:setVel(ballVelocity.x, -ballVelocity.y)
    elseif colSurface == CollisionSurface.LEFT then
        ball:setPos(bounds.x0 - (currentPos.x - bounds.x0), currentPos.y)
        ball:setVel(-ballVelocity.x, ballVelocity.y)
    end
end

-- What hell did I bring onto Earth
function Collider:collisionSurface(ball, box)

    local bounds = box:getBounds()
    local prevPos = ball:getPosLast()

    local orientiation = PossibleCollisions.BOTTOM_LEFT
    local closestPos = PositionVector:new(bounds.x0, bounds.y0)

    -- This is the worst code I've written in years
    if prevPos.x <= bounds.x0 then
        if prevPos.y <= bounds.y1 then
            orientiation = PossibleCollisions.TOP_LEFT
            closestPos = PositionVector:new(bounds.x0, bounds.y1)
        elseif prevPos.y <= bounds.y0 then
            return CollisionSurface.LEFT
        else
            orientiation = PossibleCollisions.BOTTOM_LEFT
            closestPos = PositionVector:new(bounds.x0, bounds.y0)
        end
    elseif prevPos.x < bounds.x1 then
        if prevPos.y < bounds.y1 then
            return CollisionSurface.TOP
        else
            return CollisionSurface.BOTTOM
        end
    else
        if prevPos.y <= bounds.y1 then
            orientiation = PossibleCollisions.TOP_RIGHT
            closestPos = PositionVector:new(bounds.x1, bounds.y1)
        elseif prevPos.y <= bounds.y0 then
            return CollisionSurface.RIGHT
        else
            orientiation = PossibleCollisions.BOTTOM_RIGHT
            closestPos = PositionVector:new(bounds.x1, bounds.y0)
        end
    end

    local vel = ball:getVel()
    local crossProduct = vel:cross(closestPos - prevPos)

    if crossProduct < 0 then
        return orientiation.negative
    end
    return orientiation.positive
end
