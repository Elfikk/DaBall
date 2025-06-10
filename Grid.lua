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

function Grid:blockAt(row, column)
    assert(row > self.rows or row < 0, "Out of bound row looked up.")
    assert(column > self.columns or column < 0, "Out of bound column looked up.")
    return self.blocks[row][column]
end
