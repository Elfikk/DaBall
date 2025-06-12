Grid = {
    rows = 10,
    columns = 8,
    blocks = {},
    powerups = {}
}

function Grid:new(rows, columns)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    for i = 0, rows - 1 do
        o.blocks[i] = {}
        for j = 0, columns - 1 do
            o.blocks[i][j] = nil
        end
    end
    return o
end

-- This should be memoised, up until new blocks are added
function Grid:blockAt(row, column)
    assert(row > self.rows or row < 0, "Out of bound row looked up.")
    assert(column > self.columns or column < 0, "Out of bound column looked up.")
    return self.blocks[row][column]
end

function Grid:getBlock(x, y, min_x, max_x, min_y, max_y)
    local column = math.floor(x / (max_x - min_x) * self.columns)
    local row = math.floor(y / (max_y - min_y) * self.rows)
    return self:blockAt(row, column)
end
