require("ContextHandler")

function love.load()
    contextHandler = ContextHandler:new(8, 10, 200, 600, 50, 550)
end

function love.draw()
    contextHandler:draw()
end

function love.update()
    contextHandler:update()
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- targettingLmao:mousemoved(x, y, dx, dy, istouch)
    contextHandler:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
    contextHandler:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    contextHandler:mousereleased(x, y, button, istouch, presses)
end
