require("Palettes")
require("ShapeDrawer")

Counter = {
    count = 0,
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    colour = CurrentTheme.counterColours,
}

function Counter:new(startingCount, x, y, width, height)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.count = startingCount
    o.x = x
    o.y = y
    o.width = width
    o.height = height
    return o
end

function Counter:increment(count)
    self.count = self.count + count
end

function Counter:setCount(count)
    self.count = count
end

function Counter:draw()
    ShapeDrawer:drawRectangle(self.x, self.y, self.width, self.height, self.colour, self.count, TextAlignment.CENTRE)
end
