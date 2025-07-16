require("Counter")

CounterTypes = {
    GRID_SUM = {},
    TURNS = {},
}

CounterHandler = {
    counters = {},
}

function CounterHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CounterHandler:makeCounters(x0, y0, x1, width, height)
    self.counters[CounterTypes.GRID_SUM] = Counter:new(1, x0, y0, width, height)
    self.counters[CounterTypes.TURNS] = Counter:new(2, x1 - width, y0, width, height)
end

function CounterHandler:setCount(type, count)
    self.counters[type]:setCount(count)
end

function CounterHandler:draw()
    for id, counter in pairs(self.counters) do
        counter:draw()
    end
end
