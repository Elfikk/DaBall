require("ShapeDrawer")
require("TargetContext")

TargetDrawer = {
    targetContext = TargetContext,
    targetColours = {
        colour = {r = 1.0, g = 0.0, b = 0.0},
    },
    startColours = {
        outline = {r = 1.0, g = 0.0, b = 0.0},
        text = {r = 1.0, g = 1.0, b = 1.0}
    },
}

function TargetDrawer:new(targetter)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.targetContext = targetter
    return o
end

function TargetDrawer:draw(adapter)
    local startPosition = self.targetContext:startPosition()
    if self.targetContext:isAiming() then
        local aimedAt = self.targetContext:aimingAt()
        love.graphics.line(startPosition.x, startPosition.y, aimedAt.x, aimedAt.y)
    end
    ShapeDrawer:drawCircle(
        startPosition.x,
        startPosition.y,
        3,
        self.startColours,
        "x"..self.targetContext:numberBalls(),
        TextAlignment.OUTSIDE + TextAlignment.TOP + TextAlignment.RIGHT
    )
end

