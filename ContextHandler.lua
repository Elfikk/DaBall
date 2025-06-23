require("Context")
require("FiringContext")
require("Grid")
require("GridViewportAdapter")
require("TargetContext")

Contexts = {
    TARGET = {},
    FIRE = {},
    BASE = {},
}

ContextHandler = {
    currentContextType = Contexts.BASE,
    grid = Grid,
    coordinateAdapter = GridViewportAdapter,
    contexts = {[Contexts.BASE] = Context},
    turns = 1
}

function ContextHandler:new(cols, rows, viewportX0, viewportX1, viewportY0, viewportY1)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    self.coordinateAdapter = GridViewportAdapter:new(cols, rows, viewportX0, viewportX1, viewportY0, viewportY1)
    self.grid = Grid:new(rows, cols)
    self.contexts[Contexts.TARGET] = TargetContext:new((viewportX1 - viewportX0) / 2 + viewportX0, viewportY1)
    self.contexts[Contexts.FIRE] = FiringContext:new(cols, rows)
    self.grid:generateNextTurn(self.turns)
    self.currentContextType = Contexts.TARGET
    return o
end

function ContextHandler:draw()
    self.grid:draw(self.coordinateAdapter)
    self.contexts[self.currentContextType]:draw(self.coordinateAdapter)
end

function ContextHandler:update()
    local currentContext = self.contexts[self.currentContextType]
    currentContext:update(self.grid)
    -- Incorporate transition here. Should a context know when it's finished? isActive()?
    if not currentContext:isActive() then
        -- print("not active")
        -- print(self.currentContextType, Contexts.TARGET, Contexts.FIRE, Contexts.BASE )
        if self.currentContextType == Contexts.TARGET then
            -- print(1)
            local direction = currentContext:getTargetDirection()
            self.contexts[Contexts.FIRE]:setFiringDirection(direction)
            currentContext:reset()
            self.currentContextType = Contexts.FIRE
        elseif self.currentContextType == Contexts.FIRE then
            -- print("firing")
            local gridFiringPosition = currentContext:getNextFiringPosition()
            local viewportFiringPos = self.coordinateAdapter:gridToViewportCoordinate(gridFiringPosition.x, gridFiringPosition.y)
            self.contexts[Contexts.FIRE]:reset()
            self.currentContextType = Contexts.TARGET
            self.contexts[Contexts.TARGET]:setBallPosition(viewportFiringPos)
            self.contexts[Contexts.TARGET]:setActive(true)
            self.turns = self.turns + 1
            if self.grid:generateNextTurn(self.turns) == GameOutcome.LOSS then
                self.currentContextType = Contexts.BASE
            end
        end
    end
end

function ContextHandler:mousemoved(x, y, dx, dy, istouch)
    self.contexts[self.currentContextType]:mousemoved(x, y, dx, dy, istouch)
end

function ContextHandler:mousepressed(x, y, button, istouch, presses)
    self.contexts[self.currentContextType]:mousepressed(x, y, button, istouch, presses)
end

function ContextHandler:mousereleased(x, y, button, istouch, presses)
    self.contexts[self.currentContextType]:mousepressed(x, y, button, istouch, presses)
end
