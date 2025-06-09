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
