Box = {
    bounds = {x0 = 0, x1 = 0, y0 = 0, y1 = 0}
}

function Box:new(x0, x1, y0, y1)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.bounds = {x0 = x0, x1 = x1, y0 = y0, y1 = y1}
    return o
end

function Box:getBounds()
    return self.bounds
end

function Box:inside(x, y)
    return (self.bounds.x0 < x) and (self.bounds.x1 > x) and (self.bounds.y0 < y) and (self.bounds.y1 > y)
end

function Box:below(y)
    return y > self.bounds.y1
end
