require("Block")
require("Circle")

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
        o.powerups[i] = {}
        for j = 0, columns - 1 do
            o.blocks[i][j] = nil
            o.powerups[i][j] = nil
        end
    end
    return o
end

function Grid:blockAt(row, column)
    assert(row <= self.rows - 1 and row >= 0, "Out of bound row looked up.")
    assert(column <= self.columns - 1 and column >= 0, "Out of bound column looked up.")
    return self.blocks[row][column]
end

function Grid:powerupAt(row, column)
    assert(row <= self.rows - 1 and row >= 0, "Out of bound row looked up.")
    assert(column <= self.columns - 1 and column >= 0, "Out of bound column looked up.")
    return self.powerups[row][column]
end


function Grid:getBlock(x, y, min_x, max_x, min_y, max_y)
    local column = math.floor(x / (max_x - min_x) * self.columns)
    local row = math.floor(y / (max_y - min_y) * self.rows)
    return self:blockAt(row, column)
end

function Grid:cleanupElements()
    for i = 0, self.rows - 1 do
        for j = 0, self.columns - 1 do
            if self.blocks[i][j] ~= nil then
                if not self.blocks[i][j]:isValid() then
                    self.blocks[i][j] = nil
                end
            elseif self.powerups[i][j] ~= nil then
                if not self.powerups[i][j]:isValid() then
                    self.powerups[i][j] = nil
                end
            end
        end
    end
end

function Grid:generateNextTurn(hitpoints)
    self:moveElementsDown()
    local outcome = self:checkIntegrity()
    if outcome == GameOutcome.CONTINUE then
        local addedBlocks = self:addBlocks(hitpoints)
        self:addBalls(addedBlocks)
    end
    return outcome
end

function Grid:moveElementsDown()
    for j = 0, self.columns - 1 do
        for i = self.rows - 1, 0, -1 do
            self.blocks[i + 1][j] = self.blocks[i][j]
            self.powerups[i + 1][j] = self.powerups[i][j]
            if self.blocks[i + 1][j] ~= nil then
                self.blocks[i + 1][j]:moveVertically(1)
            elseif self.powerups[i + 1][j] ~= nil then
                self.powerups[i + 1][j]:moveDown(1)
            end
        end
        self.blocks[0][j] = nil
        self.powerups[0][j] = nil
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
            self.blocks[0][j] = Block:new(j, j + 1, 1, 0, hitpoints)
            added = added + 1
            -- -- print("added at", j)
        end
    end

    if added == 0 then
        -- Always have at least one
        local col = math.random(0, self.columns - 1)
        self.blocks[0][col] = Block:new(col, col + 1, 1, 0, hitpoints)
    elseif added == self.columns then
        -- But always leave space for a powerup...
        local col = math.random(0, self.columns - 1)
        self.blocks[0][col] = nil
    end
    return added
end

function Grid:addBalls(addedBlocks)
    local possibleColumns = self.columns - addedBlocks
    local addAfter = math.random(0, possibleColumns - 1)
    for i = 0, self.columns - 1 do
        if self.blocks[0][i] == nil then
            if addAfter == 0 then
                -- -- print("added ball at", i)
                self.powerups[0][i] = Circle:new(i + 0.5, 0.5, 0.25)
                return
            end
            addAfter = addAfter - 1
        end
    end
end

function Grid:draw(adapter)
    for i = 0, self.rows - 1 do
        for j = 0, self.columns - 1 do
            if self.blocks[i][j] ~= nil then
                local bounds = self.blocks[i][j]:getBounds()
                local viewportPos = adapter:gridToViewportCoordinate(bounds.x0, bounds.y1)
                local width = adapter:gridToViewportWidth(bounds.x1 - bounds.x0)
                local height = adapter:gridToViewportWidth(bounds.y0 - bounds.y1)
                love.graphics.setColor(0, 0.5, 0.5)
                love.graphics.rectangle("fill", viewportPos.x, viewportPos.y, width, height)
                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.print( self.blocks[i][j]:getHitpoints(), viewportPos.x + 0.4 * width, viewportPos.y + 0.4 * height)
            end
            if self.powerups[i][j] ~= nil then
                local pos = self.powerups[i][j]:getPos()
                local viewportPos = adapter:gridToViewportCoordinate(pos.x, pos.y)
                local radius = adapter:gridToViewportWidth(self.powerups[i][j]:getRadius())
                love.graphics.setColor(0, 0.5, 0)
                love.graphics.circle("fill", viewportPos.x, viewportPos.y, radius)
                love.graphics.setColor(0.8, 0.8, 0.8)
            end
        end
    end
    local minBoundaries = adapter:gridToViewportCoordinate(0, 0)
    local maxBoundaries = adapter:gridToViewportCoordinate(self.columns, self.rows)
    love.graphics.setColor(0.8, 0, 0)
    love.graphics.rectangle("line", minBoundaries.x, minBoundaries.y, maxBoundaries.x - minBoundaries.x, maxBoundaries.y - minBoundaries.y)
    love.graphics.setColor(0.8, 0.8, 0.8)
end
