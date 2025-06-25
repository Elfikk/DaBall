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
    print("mouse pressed", x, y)
    if self.active then
        if not self.aiming then
            print("")
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
    -- print(x, y)
    if self.aimedAt.y < self.ballPosition.y then
        self.active = false
        return
    end
    self.aiming = false
end

function TargetContext:isActive()
    return self.active
end

function TargetContext:draw(adapter)
    if self.aiming then
        love.graphics.line(self.ballPosition.x, self.ballPosition.y, self.aimedAt.x, self.aimedAt.y)
    end
    love.graphics.circle("fill", self.ballPosition.x, self.ballPosition.y, 3)
    love.graphics.print("x"..self.numBalls, self.ballPosition.x * 1.01, self.ballPosition.y * 0.97)
end

function TargetContext:setBallPosition(pos)
    self.ballPosition = pos
end

function TargetContext:setNumBalls(num)
    self.numBalls = num
end

function TargetContext:getTargetDirection()
    local positionVector = self.aimedAt - self.ballPosition
    -- print("Ball Starting Coordinate", self.ballPosition.x, self.ballPosition.y)
    -- print("Ball Crosshair Aimed At", self.aimedAt.x, self.aimedAt.y)
    -- print("Difference", positionVector.x, positionVector.y)
    return positionVector:directionVector()
end

function TargetContext:setActive(set)
    self.active = set
end

function TargetContext:reset()
    self.aiming = false
end