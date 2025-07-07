require("ContextHandler")
require("Counter")

function love.load()
    math.randomseed(os.time())
    local width = 1200
    local height = 900
    love.window.setMode(width, height)

    local cols = 8
    local rows = 10

    local blockSize = math.min(width / cols, height / rows) / 4 * 3
    local gridWidth = blockSize * cols
    local gridHeight = blockSize * rows
    local gridOffsetX = (width - gridWidth) / 2
    local gridOffsetY = (height - gridHeight) / 2
    contextHandler = ContextHandler:new(cols, rows, gridOffsetX, gridOffsetX + gridWidth, gridOffsetY, gridOffsetY + gridHeight)
    -- Not like this eh
    turnCounter = Counter:new(1, gridOffsetX, gridOffsetY + gridHeight + blockSize / 10, (cols / 2 - 1) * blockSize, blockSize / 2)
    hitpointCounter = Counter:new(2, gridOffsetX + gridWidth - (cols / 2 - 1) * blockSize, gridOffsetY + gridHeight + blockSize / 10, (cols / 2 - 1) * blockSize, blockSize / 2)

    shader = love.graphics.newShader("ShaderMessAround/grid.love.glsl")

    love.graphics.setNewFont(18)
end

function love.draw()
    love.graphics.setShader(shader)
    contextHandler:draw()
    turnCounter:draw()
    hitpointCounter:draw()
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function love.update()
    contextHandler:update()
    turnCounter:setCount(contextHandler:getTurns())
    hitpointCounter:setCount(contextHandler:getGridSum())
end

function love.mousemoved(x, y, dx, dy, istouch)
    contextHandler:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
    contextHandler:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    contextHandler:mousereleased(x, y, button, istouch, presses)
end
