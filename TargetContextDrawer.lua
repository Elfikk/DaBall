require("Palettes")
require("ShapeDrawer")
require("TargetContext")

TargetDrawer = {
    targetContext = TargetContext,
    targetColours = CurrentTheme.targetColours,
    startColours = CurrentTheme.markerColour,
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
        ShapeDrawer:drawLine(startPosition.x, startPosition.y, aimedAt.x, aimedAt.y, self.targetColours)
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

