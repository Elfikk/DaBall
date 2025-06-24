Counter = {
    count = 0,
    x = 0,
    y = 0,
    width = 0,
    height = 0,
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
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)

    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.count)
    local offsetX = (self.width - textWidth) / 2
    local textHeight = font:getHeight(self.count)
    local offsetY = (self.height - textHeight) / 2
    love.graphics.print(self.count, self.x + offsetX, self.y + offsetY)
    love.graphics.setColor(0.6, 0.6, 0.6)
end
