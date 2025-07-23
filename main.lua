require("ButtonHandler")
require("ContextHandler")
require("CounterHandler")
require("GameHandler")
require("Saver")

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

    contextHandler = nil
    if Saver:saveFilesExist() then
        contextHandler = ContextHandler:fromSave(gridOffsetX, gridOffsetX + gridWidth, gridOffsetY, gridOffsetY + gridHeight, Saver:loadContextState())
    else
        contextHandler = ContextHandler:new(cols, rows, gridOffsetX, gridOffsetX + gridWidth, gridOffsetY, gridOffsetY + gridHeight)
    end
    -- Not like this eh

    local xMax = gridOffsetX + gridWidth
    local counterY = gridOffsetY + gridHeight + blockSize / 10
    local counterWidth = (cols / 2 - 1) * blockSize
    local counterHeight = blockSize / 2

    counterHandler = CounterHandler:new()
    counterHandler:makeCounters(gridOffsetX, counterY, xMax, counterWidth, counterHeight)

    buttonHandler = ButtonHandler:new()
    buttonHandler:makeButtons(
        gridOffsetX,
        gridOffsetX + gridWidth,
        gridOffsetY + gridHeight + blockSize,
        gridOffsetY + gridHeight + 1.5 * blockSize
    )
    buttonHandler:makeVisible(ButtonTypes.PAUSE)
    buttonHandler:makeVisible(ButtonTypes.QUIT)

    gameHandler = GameHandler:new(buttonHandler, contextHandler, counterHandler)

    shader = love.graphics.newShader("ShaderMessAround/grid.love.glsl")

    love.graphics.setNewFont(18)
end

function love.draw()
    love.graphics.setShader(shader)
    gameHandler:draw()
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function love.update()
    gameHandler:update()
end

function love.mousemoved(x, y, dx, dy, istouch)
    gameHandler:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
    gameHandler:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    gameHandler:mousereleased(x, y, button, istouch, presses)
end
