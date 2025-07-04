require("FiringContext")
require("ShapeDrawer")

FiringDrawer = {
    ballColour = {
        fill = {r = 1, g = 0, b = 0},
    },
    firingContext = FiringContext,
}

function FiringDrawer:new(firing)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.firingContext = firing
end

function FiringDrawer:draw(adapter)
    for id, ball in pairs(self.firingContext.activeBalls) do
        local viewportPos = adapter:gridToViewportCoordinate(ball.posNow.x, ball.posNow.y)
        ShapeDrawer:drawCircle(viewportPos.x, viewportPos.y, 3, self.ballColour, nil, nil)
    end
    if self.firingContext.nextFiringPosition ~= nil then
        local markerPos = self.firingContext.nextFiringPosition
        local viewportPos = adapter:gridToViewportCoordinate(markerPos.x, markerPos.y)
        ShapeDrawer:drawCircle(viewportPos.x, viewportPos.y, 3, self.ballColour, nil, nil)
    end
end
