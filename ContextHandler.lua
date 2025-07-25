require("Context")
require("FiringContext")
require("FiringContextDrawer")
require("Grid")
require("GridDrawer")
require("GridViewportAdapter")
require("Saver")
require("TargetContext")
require("TargetContextDrawer")

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
    turns = 1,
    gridSum = 0,
    gridDrawer = GridDrawer, -- temporary
    targetDrawer = TargetDrawer,
    firingDrawer = FiringDrawer,
}

function ContextHandler:new(cols, rows, viewportX0, viewportX1, viewportY0, viewportY1)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.coordinateAdapter = GridViewportAdapter:new(cols, rows, viewportX0, viewportX1, viewportY0, viewportY1)
    o.grid = Grid:new(rows, cols)
    o.contexts[Contexts.TARGET] = TargetContext:new((viewportX1 - viewportX0) / 2 + viewportX0, viewportY1)
    o.contexts[Contexts.FIRE] = FiringContext:new(cols, rows)
    o.grid:generateNextTurn(o.turns)
    o.gridSum = o.grid:getAddedHitpoints()
    o.gridDrawer = GridDrawer:new(o.grid)
    o.targetDrawer = TargetDrawer:new(o.contexts[Contexts.TARGET])
    o.firingDrawer = FiringDrawer:new(o.contexts[Contexts.FIRE])
    o.currentContextType = Contexts.TARGET
    return o
end

function ContextHandler:fromSave(viewportX0, viewportX1, viewportY0, viewportY1, numTurns)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.grid, o.contexts[Contexts.FIRE] = Saver:loadObjects()
    o.coordinateAdapter = GridViewportAdapter:new(o.grid.columns, o.grid.rows, viewportX0, viewportX1, viewportY0, viewportY1)
    o.contexts[Contexts.TARGET] = TargetContext:new((viewportX1 - viewportX0) / 2 + viewportX0, viewportY1)
    local gridFiringPosition = o.contexts[Contexts.FIRE]:getFiringPosition()
    local viewportFiringPos = o.coordinateAdapter:gridToViewportCoordinate(gridFiringPosition.x, gridFiringPosition.y)
    o.contexts[Contexts.TARGET]:setBallPosition(viewportFiringPos)
    o.contexts[Contexts.TARGET]:setNumBalls(o.contexts[Contexts.FIRE]:getNumBalls())
    o.gridDrawer = GridDrawer:new(o.grid)
    o.targetDrawer = TargetDrawer:new(o.contexts[Contexts.TARGET])
    o.firingDrawer = FiringDrawer:new(o.contexts[Contexts.FIRE])
    o.currentContextType = Contexts.TARGET
    o.gridSum = o.grid:getAddedHitpoints()
    o.turns = numTurns
    return o
end

-- Want to maintain most parameters here, but just get rid of progress so far?
-- We should also delete the Saver's saves
function ContextHandler:restartReset()
    -- All the objects the context handler manages
    self.contexts[Contexts.FIRE]:restartReset()
    self.contexts[Contexts.TARGET]:restartReset()
    local firePosition = self.contexts[Contexts.FIRE]:getFiringPosition()
    local viewportFiringPos = self.coordinateAdapter:gridToViewportCoordinate(firePosition.x, firePosition.y)
    self.contexts[Contexts.TARGET]:setBallPosition(viewportFiringPos)
    self.grid:restartReset()
    self.currentContextType = Contexts.TARGET
    self.currentContext = self.contexts[Contexts.TARGET]
    Saver:restartReset()

    -- Itself
    self.turns = 1
    self.gridSum = self.grid:getAddedHitpoints()
end

function ContextHandler:draw()
    self.gridDrawer:draw(self.coordinateAdapter)
    if self.currentContextType == Contexts.TARGET then
        self.targetDrawer:draw(self.coordinateAdapter)
    elseif self.currentContextType == Contexts.FIRE then
        self.firingDrawer:draw(self.coordinateAdapter)
    end
end

function ContextHandler:update()
    local currentContext = self.contexts[self.currentContextType]
    currentContext:update(self.grid)
    if self.currentContextType == Contexts.FIRE then
        self.gridSum = self.gridSum - currentContext:getHitBlockCount()
    end
    -- Incorporate transition here. Should a context know when it's finished? isActive()?
    if not currentContext:isActive() then
        if self.currentContextType == Contexts.TARGET then
            local direction = currentContext:getTargetDirection()
            self.contexts[Contexts.FIRE]:setFiringDirection(direction)
            currentContext:reset()
            self.currentContextType = Contexts.FIRE
        elseif self.currentContextType == Contexts.FIRE then
            local gridFiringPosition = currentContext:getNextFiringPosition()
            local viewportFiringPos = self.coordinateAdapter:gridToViewportCoordinate(gridFiringPosition.x, gridFiringPosition.y)
            self.contexts[Contexts.FIRE]:reset()
            self.currentContextType = Contexts.TARGET
            self.contexts[Contexts.TARGET]:setBallPosition(viewportFiringPos)
            self.contexts[Contexts.TARGET]:setActive(true)
            self.turns = self.turns + 1
            if self.grid:generateNextTurn(self.turns) == GameOutcome.LOSS then
                self.currentContextType = Contexts.BASE
                Saver:restartReset()
                return nil
            else
                self.gridSum = self.gridSum + self.grid:getAddedHitpoints()
            end
            self.contexts[Contexts.TARGET]:setNumBalls(self.contexts[Contexts.FIRE]:getNumBalls())
            Saver:saveGrid(self.grid)
            Saver:saveFiringState(self.contexts[Contexts.FIRE])
            Saver:saveContextState(self)
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

function ContextHandler:getTurns()
    return self.turns
end

function ContextHandler:getGridSum()
    return self.gridSum
end
