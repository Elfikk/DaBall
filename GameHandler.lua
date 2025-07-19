require("ButtonHandler")
require("ContextHandler")
require("CounterHandler")

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
        self.counters:setCount(CounterTypes.GRID_SUM, self.contextHandler:getGridSum())
        self.counters:setCount(CounterTypes.TURNS, self.contextHandler:getTurns())
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
            self.buttonHandler:makeVisible(ButtonTypes.RESTART)
        elseif self.currentState == States.PAUSED then
            self.currentState = States.PLAYING
            self.buttonHandler:setText(ButtonTypes.PAUSE, "Pause")
            self.buttonHandler:hide(ButtonTypes.RESTART)
        end
    elseif buttonType == ButtonTypes.RESTART then
        self:restartReset()
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
    self.counters:draw()
end

function GameHandler:restartReset()
    self.buttonHandler:restartReset()
    self.contextHandler:restartReset()
    self.counters:restartReset()
    self.currentState = States.PLAYING
end
