require("Grid")
require("ShapeDrawer")

GridDrawer = {
    blockColours = {
        fill = {r = 0.5, g = 0.5, b = 0.5},
        outline = {r = 1, g = 1, b = 1},
        text = {r = 0.8, g = 0.8, b = 0.8},
    },
    boundColours = {
        outline = {r = 0.8, g = 0, b = 0},
    },
    powerupColour = {
        fill = {r = 0, g = 0.5, b = 0},
    },
    grid = Grid,
}

function GridDrawer:new(grid)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.grid = grid
    return o
end

function GridDrawer:draw(adapter)
    for i = 0, self.grid.rows - 1 do
        for j = 0, self.grid.columns - 1 do
            if self.grid.blocks[i][j] ~= nil then
                local bounds = self.grid.blocks[i][j]:getBounds()
                local viewportPos = adapter:gridToViewportCoordinate(bounds.x0, bounds.y1)
                local width = adapter:gridToViewportWidth(bounds.x1 - bounds.x0)
                local height = adapter:gridToViewportWidth(bounds.y0 - bounds.y1)
                self:drawBlock(self.grid.blocks[i][j]:getHitpoints(), viewportPos.x, viewportPos.y, width, height)
            end
            if self.grid.powerups[i][j] ~= nil then
                local pos = self.grid.powerups[i][j]:getPos()
                local viewportPos = adapter:gridToViewportCoordinate(pos.x, pos.y)
                local radius = adapter:gridToViewportWidth(self.grid.powerups[i][j]:getRadius())
                self:drawPowerup(viewportPos.x, viewportPos.y, radius)
            end
        end
    end
    local minBound = adapter:gridToViewportCoordinate(0, 0)
    local maxBound = adapter:gridToViewportCoordinate(self.grid.columns, self.grid.rows)
    self:drawBoundingBox(minBound.x, minBound.y, maxBound.x - minBound.x, maxBound.y - minBound.y)
end

function GridDrawer:drawBlock(hp, x, y, width, height)
    ShapeDrawer:drawRectangle(x, y, width, height, self.blockColours, hp, TextAlignment.CENTRE)
end

function GridDrawer:drawPowerup(x, y, r)
    ShapeDrawer:drawCircle(x, y, r, self.powerupColour, nil, 0)
end

function GridDrawer:drawBoundingBox(x, y, width, height)
    ShapeDrawer:drawRectangle(x, y, width, height, self.boundColours, nil, 0)
end
