require("Block")

Grid = {
    rows = 10,
    columns = 8,
    blocks = {},
    powerups = {},
    probBlock = 0.5
}

GameOutcome = {
    LOSS = {},
    CONTINUE = {},
}

function Grid:new(rows, columns)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    -- One extra row; if block in this row, game ended
    for i = 0, rows do
        o.blocks[i] = {}
        for j = 0, columns - 1 do
            o.blocks[i][j] = nil
        end
    end
    return o
end

function Grid:blockAt(row, column)
    assert(row <= self.rows - 1 and row >= 0, "Out of bound row looked up.")
    assert(column <= self.columns - 1 and column >= 0, "Out of bound column looked up.")
    return self.blocks[row][column]
end

function Grid:getBlock(x, y, min_x, max_x, min_y, max_y)
    local column = math.floor(x / (max_x - min_x) * self.columns)
    local row = math.floor(y / (max_y - min_y) * self.rows)
    return self:blockAt(row, column)
end

function Grid:cleanupBlocks()
    for i = 0, self.rows - 1 do
        for j = 0, self.columns - 1 do
            if self.blocks[i][j] ~= nil then
                if not self.blocks[i][j]:isValid() then
                    self.blocks[i][j] = nil
                end
            end
        end
    end
end

function Grid:generateNextTurn(hitpoints)
    self:moveBlocks()
    local outcome = self:checkIntegrity()
    if outcome == GameOutcome.CONTINUE then
        self:addBlocks(hitpoints)
    end
    return outcome
end

function Grid:moveBlocks()
    for j = 0, self.columns - 1 do
        for i = self.rows - 1, 0, -1 do
            self.blocks[i + 1][j] = self.blocks[i][j]
            if self.blocks[i + 1][j] ~= nil then
                -- print(i + 1)
                -- print(j)
                self.blocks[i + 1][j]:moveVertically(1)
            end
        end
        self.blocks[0][j] = nil
    end
end

function Grid:checkIntegrity()
    -- Check max row (default 11) for any blocks
    for j = 0, self.columns - 1 do
        if self.blocks[self.rows][j] ~= nil then
            return GameOutcome.LOSS
        end
    end
    return GameOutcome.CONTINUE
end

function Grid:addBlocks(hitpoints)
    local added = 0
    for j = 0, self.columns - 1 do
        if math.random() < self.probBlock then
            self.blocks[0][j] = Block:new(j, j + 1, 1, 0, 1)
            added = added + 1
        end
    end

    if added == 0 then
        -- Always have at least one
        local col = math.random(0, self.columns - 1)
        self.blocks[0][col] = Block:new(col, col + 1, 1, 0)
    elseif added == self.columns then
        -- But always leave space for a powerup...
        local col = math.random(0, self.columns - 1)
        self.blocks[0][col] = nil
    end
end

SF = 50

function Grid:draw()
    for i = 0, self.rows - 1 do
        for j = 0, self.columns - 1 do
            if self.blocks[i][j] ~= nil then
                local bounds = self.blocks[i][j]:getBounds()
                love.graphics.rectangle("line", bounds.x0 * SF, bounds.y1 * SF, (bounds.x1 - bounds.x0) * SF, (bounds.y0 - bounds.y1) * SF)
            end
        end
    end
    love.graphics.setColor(0.8, 0, 0)
    love.graphics.rectangle("line", 0, 0, self.columns * SF, self.rows * SF)
    love.graphics.setColor(0.8, 0.8, 0.8)
end
