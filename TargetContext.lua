require("Context")
require("PositionVector")

TargetContext = {
    ballPosition = PositionVector:new(300, 200),
    aimedAt = PositionVector:new(0, 0),
    active = true,
    aiming = false,
    numBalls = 1
}

function TargetContext:new(posX, posY)
    TargetContext.__index = TargetContext
    setmetatable(TargetContext, {__index = Context})
    local o = Context:new()
    setmetatable(o, self)
    self.__index = self
    o.ballPosition = PositionVector:new(posX, posY)
    return o
end

function TargetContext:mousemoved(x, y, dx, dy, istouch)
    if self.active and love.mouse.isDown(1, 2, 3) then
        self.aimedAt = PositionVector:new(x, y)
    end
end

function TargetContext:mousepressed(x, y, button, istouch, presses)
    if self.active then
        if not self.aiming then
            self.aimedAt = PositionVector:new(x, y)
            self.aiming = true
        else
            self:mousereleased(x, y, button, istouch, presses)
        end
    end
end

function TargetContext:mousereleased(x, y, button, istouch, presses)
    -- if valid position
    -- set inactive
    if self.aimedAt.y < self.ballPosition.y then
        self.active = false
        return
    end
    self.aiming = false
end

function TargetContext:isActive()
    return self.active
end

function TargetContext:setBallPosition(pos)
    self.ballPosition = pos
end

function TargetContext:setNumBalls(num)
    self.numBalls = num
end

function TargetContext:getTargetDirection()
    local positionVector = self.aimedAt - self.ballPosition
    return positionVector:directionVector()
end

function TargetContext:setActive(set)
    self.active = set
end

function TargetContext:reset()
    self.aiming = false
end

function TargetContext:isAiming()
    return self.aiming
end

function TargetContext:startPosition()
    return self.ballPosition
end

function TargetContext:aimingAt()
    return self.aimedAt
end

function TargetContext:numberBalls()
    return self.numBalls
end

function TargetContext:restartReset()
    self.aimedAt.y = self.ballPosition.y * 100
    self.numBalls = 1
    self.aiming = false
    self.active = true
end
