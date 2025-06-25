require("Box")
require("PositionVector")

GridViewportAdapter = {
    gridBox = Box:new(0, 8, 0, 10),
    viewportBox = Box:new(0, 400, 0, 300)
}

function GridViewportAdapter:new(gridCols, gridRows, viewportX0, viewportX1, viewportY0, viewportY1)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.gridBox = Box:new(0, gridCols, 0, gridRows)
    o.viewportBox = Box:new(viewportX0, viewportX1, viewportY0, viewportY1)
    return o
end

function GridViewportAdapter:gridToViewportCoordinate(grid_col, grid_row)
    local gridBounds = self.gridBox:getBounds()
    assert(grid_col >= gridBounds.x0 and grid_col <= gridBounds.x1, "Passed grid column outside coordinates.")
    assert(grid_row >= gridBounds.y0 and grid_row <= gridBounds.y1, "Passed grid row outside coordinates.")

    local viewportBounds = self.viewportBox:getBounds()

    local width_scale = (viewportBounds.x1 - viewportBounds.x0) / (gridBounds.x1 - gridBounds.x0)
    local x = width_scale * (grid_col - gridBounds.x0) + viewportBounds.x0
    local y = (viewportBounds.y1 - viewportBounds.y0) * (grid_row - gridBounds.y0) / (gridBounds.y1 - gridBounds.y0) + viewportBounds.y0
    return PositionVector:new(x, y)
end

function GridViewportAdapter:viewportToGridCoordinate(viewportX, viewportY)
    local viewportBounds = self.viewportBox:getBounds()

    assert(viewportX >= viewportBounds.x0 and viewportX <= viewportBounds.x1, "Passed viewport X outside coordinates.")
    assert(viewportY >= viewportBounds.y0 and viewportY <= viewportBounds.y1, "Passed viewport Y outside coordinates.")

    local gridBounds = self.gridBox:getBounds()

    local x = (gridBounds.x1 - gridBounds.x0) * (viewportX - viewportBounds.x0) / (viewportBounds.x1 - viewportBounds.x0) + gridBounds.x0
    local y = (gridBounds.y1 - gridBounds.y0) * (viewportY - viewportBounds.y0) / (viewportBounds.y1 - viewportBounds.y0) + gridBounds.y0
    return PositionVector:new(x, y)
end

function GridViewportAdapter:gridToViewportWidth(gridWidth)
    local gridBounds = self.gridBox:getBounds()
    local viewportBounds = self.viewportBox:getBounds()
    return gridWidth / (gridBounds.x1 - gridBounds.x0) * (viewportBounds.x1 - viewportBounds.x0)
end

function GridViewportAdapter:gridToViewportHeight(gridHeight)
    local gridBounds = self.gridBox:getBounds()
    local viewportBounds = self.viewportBox:getBounds()
    return gridHeight / (gridBounds.y1 - gridBounds.y0) * (viewportBounds.y1 - viewportBounds.y0)
end
