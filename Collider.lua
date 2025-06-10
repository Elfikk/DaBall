require("PositionVector")

Collider = {}

CollisionSurface = {
    TOP = {},
    RIGHT = {},
    BOTTOM = {},
    LEFT = {}
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
    local currentPos = ball:getPos()
    local velocity = ball:getVel()

    local function critTime(bound, pos, vel)
        if vel == 0 then
            return 10
        end
        return (pos - bound) / vel
    end

    local smallestTime = -100000
    local surface = CollisionSurface.TOP

    local topTime = critTime(currentPos.y, bounds.y1, velocity.y)
    if smallestTime < topTime and topTime <= 0 then
        smallestTime = topTime
        surface = CollisionSurface.TOP
    end

    local bottomTime = critTime(currentPos.y, bounds.y0, velocity.y)
    if smallestTime < bottomTime and bottomTime <= 0 then
        smallestTime = bottomTime
        surface = CollisionSurface.BOTTOM
    end

    local rightTime = critTime(currentPos.x, bounds.x1, velocity.x)
    if smallestTime < rightTime and rightTime <= 0 then
        smallestTime = rightTime
        surface = CollisionSurface.RIGHT
    end

    local leftTime = critTime(currentPos.x, bounds.x0, velocity.x)
    if smallestTime < leftTime and leftTime <= 0 then
        smallestTime = leftTime
        surface = CollisionSurface.LEFT
    end
    return surface
end
