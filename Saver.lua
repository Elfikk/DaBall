require("Block")
require("Circle")
require("Grid")
require("io")

Saver = {
    contextPath = love.filesystem.getSaveDirectory() .. "/ContextHandler.csv",
    firingPath = love.filesystem.getSaveDirectory() .. "/FiringContext.csv",
    gridPath = love.filesystem.getSaveDirectory() .. "/Grid.csv",
}

function Saver:saveGrid(grid)
    local csvString = ""
    for i = 0, grid.rows do
        for j = 0, grid.columns - 1 do
            if grid.blocks[i][j] ~= nil then
                csvString = csvString .. grid.blocks[i][j]:getHitpoints() .. ","
            elseif grid.powerups[i][j] ~= nil then
                csvString = csvString .. "o,"
            else
                csvString = csvString .. "x,"
            end
        end
        csvString = csvString .. ",\n"
    end

    -- probably should check whether we have write access first icl
    local f = assert(io.open(Saver.gridPath, "w+"))
    f:write(csvString)
    f:close()
end

function Saver:saveFiringState(firingContext)
    -- need firing position and number of balls
    local firingFrom = firingContext:getFiringPosition()
    local numBalls = firingContext:getNumBalls()
    local saveString = "" .. firingFrom.x .. "," .. firingFrom.y .. "," .. numBalls .. ","
    local f = assert(io.open(Saver.firingPath, "w+"))
    f:write(saveString)
    f:close()
end

function Saver:saveContextState(contextHandler)
    -- This just saves a count lol
    local turns = contextHandler:getTurns()
    local saveString = "" .. turns .. ","
    local f = assert(io.open(Saver.contextPath, "w+"))
    f:write(saveString)
    f:close()
end

function Saver:loadGridState()
    local f = assert(io.open(Saver.gridPath, "r"))
    local rows = 0
    local cols = 0

    local powerups = {}
    local blocks = {}
    local blockCount = 0

    for line in f:lines("l") do
        powerups[rows] = {}
        blocks[rows] = {}
        local currStr = ""
        cols = 0
        for i = 1, #line do
            local character = line:sub(i, i)
            if character == "," then
                -- Handle formed string
                if currStr == "x" then
                    -- do nothing
                elseif currStr == "o" then
                    powerups[rows][cols] = Circle:new(cols + 0.5, rows + 0.5, 0.25)
                    print("new circle at " .. cols + 0.5 .. "," .. rows + 0.5)
                elseif currStr == "" then
                    -- skip, happens as last character
                else
                    -- must be numeric value
                    -- print(currStr)
                    local count = tonumber(currStr)
                    blockCount = blockCount + count
                    blocks[rows][cols] = Block:new(cols, cols + 1, rows, rows + 1, count)
                    print("new block at " .. cols .. "," .. rows)
                end
                currStr = ""
                cols = cols + 1
            else
                currStr = currStr .. character
            end
        end
        rows = rows + 1
    end
    f:close()

    rows = rows - 1
    cols = cols - 1

    print(rows, cols)
    return rows, cols, blocks, powerups, blockCount
end

function Saver:loadContextState()
    local f = assert(io.open(Saver.contextPath, "r"))
    local gameState = f:read("a")
    f:close()

    local strings = {}
    local currStr = ""
    local strNum = 0
    for i = 1, #gameState do
        local character = gameState:sub(i, i)
        if character == "," then
            strings[strNum] = currStr
            currStr = ""
            strNum = strNum + 1
        else
            currStr = currStr .. character
        end
    end

    local turns = tonumber(strings[0])
    print("Context " .. turns)
    return turns
end

function Saver:loadGameState()
    -- format:
    -- "" .. firingFrom.x .. "," .. firingFrom.y .. "," .. numBalls
    local f = assert(io.open(Saver.firingPath, "r"))
    local gameState = f:read("a")
    f:close()
    local strings = {}
    local currStr = ""
    local strNum = 0
    for i = 1, #gameState do
        local character = gameState:sub(i, i)
        if character == "," then
            strings[strNum] = currStr
            currStr = ""
            strNum = strNum + 1
        else
            currStr = currStr .. character
        end
    end

    local x = tonumber(strings[0])
    local y = tonumber(strings[1])
    local numBalls = tonumber(strings[2])

    return x, y, numBalls
end

function Saver:loadObjects()
    local rows, cols, blocks, powerups, blockCount = Saver:loadGridState()
    local firingX, firingY, numBalls = Saver:loadGameState()
    local grid = Grid:fromSave(rows, cols, blocks, powerups, blockCount)
    local firingContext = FiringContext:fromSave(cols, rows, firingX, firingY, numBalls)
    return grid, firingContext
end

function Saver:fileExists(filePath)
    local file = io.open(filePath, "r")
    return file ~= nil and io.close(file)
end

function Saver:saveFilesExist()
    return self:fileExists(self.gridPath) and self:fileExists(self.firingPath) and self:fileExists(self.contextPath)
end

function Saver:restartReset()
    -- Delete previous gamefiles
    os.remove(self.contextPath)
    os.remove(self.firingPath)
    os.remove(self.gridPath)
end
