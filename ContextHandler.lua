require("Context")
require("Grid")

ContextHandler = {
    currentContext = Context,
    grid = Grid
}

function ContextHandler:draw()
    self.currentContext:draw()
end

function ContextHandler:update()
    self.currentContext:update()
    -- Incorporate transition here. Should a context know when it's finished? isActive()?
end
