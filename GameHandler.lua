require("ButtonHandler")
require("ContextHandler")

States = {
    PAUSED = {},
    PLAYING = {},
}

GameHandler = {
    buttonHandler = ButtonHandler,
    contextHandler = ContextHandler,
    counters = {},
    currentState = States.PLAYING,
}

function GameHandler:new(buttons, contexts, counters)
    local o = {}
    self.__index = self
    setmetatable(o, self)
    o.buttonHandler = buttons
    o.contextHandler = contexts
    o.counters = counters
    return o
end

function GameHandler:update()
    if self.currentState == States.PLAYING then
        self.contextHandler:update()
    end
end

function GameHandler:mousepressed(x, y, button, istouch, presses)
    local buttonType = self.buttonHandler:mousepressed(x, y, button, istouch, presses)
    if buttonType == nil then
        if self.currentState == States.PLAYING then
            self.contextHandler:mousepressed(x, y, button, istouch, presses)
        end
    elseif buttonType == ButtonTypes.PAUSE then
        if self.currentState == States.PLAYING then
            self.currentState = States.PAUSED
            self.buttonHandler:setText(ButtonTypes.PAUSE, "Resume")
        elseif self.currentState == States.PAUSED then
            self.currentState = States.PLAYING
            self.buttonHandler:setText(ButtonTypes.PAUSE, "Pause")
        end
    elseif buttonType == ButtonTypes.RESTART then
        -- Restart LMAO
    elseif buttonType == ButtonTypes.QUIT then
        love.event.quit(0)
    end
end

function GameHandler:mousereleased(x, y, button, istouch, presses)
    if self.currentState == States.PLAYING then
        self.contextHandler:mousereleased(x, y, button, istouch, presses)
    end
end

function GameHandler:mousemoved(x, y, dx, dy, istouch)
    if self.currentState == States.PLAYING then
        self.contextHandler:mousemoved(x, y, dx, dy, istouch)
    end
end

function GameHandler:draw()
    self.buttonHandler:draw()
    self.contextHandler:draw()
end
