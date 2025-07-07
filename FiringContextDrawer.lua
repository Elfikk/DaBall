require("FiringContext")
require("Palettes")
require("ShapeDrawer")

FiringDrawer = {
    ballColour = CurrentTheme.ballColours,
    markerColour = CurrentTheme.markerColour,
    firingContext = FiringContext,
}

function FiringDrawer:new(firing)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.firingContext = firing
    return o
end

function FiringDrawer:draw(adapter)
    for id, ball in pairs(self.firingContext.activeBalls) do
        local viewportPos = adapter:gridToViewportCoordinate(ball.posNow.x, ball.posNow.y)
        ShapeDrawer:drawCircle(viewportPos.x, viewportPos.y, 3, self.ballColour, nil, nil)
    end
    local firingPos = self.firingContext:getNextFiringPosition()
    if firingPos ~= nil then
        local viewportPos = adapter:gridToViewportCoordinate(firingPos.x, firingPos.y)
        ShapeDrawer:drawCircle(viewportPos.x, viewportPos.y, 3, self.markerColour, nil, nil)
    end
end
