require("Box")

Block = {
    hitpoints = 1
}

function Block:new(x0, x1, y0, y1, hp)
    Block.__index = Block
    setmetatable(Block, {__index = Box})
    local o = Box:new(x0, x1, y0, y1)
    setmetatable(o, Block)
    o.__index = Block
    o.hitpoints = hp
    return o
end

function Block:decrement()
    self.hitpoints = self.hitpoints - 1
    return self:valid()
end

function Block:valid()
    return self.hitpoints > 0
end

function Block:moveVertically(delta_y)
    -- print(self.x0)
    self.bounds.y0 = self.bounds.y0 + delta_y
    self.bounds.y1 = self.bounds.y1 + delta_y
end
