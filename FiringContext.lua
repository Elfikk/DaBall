require("Ball")
require("Collider")
require("Context")
require("Grid")
require("PositionVector")

FiringContext = {
    activeBalls = {},
    collider = Collider:new(),
    boundingBox = Box:new(0, 8, 0, 10),
    firedBalls = 0,
    activeCount = 0,
    targetBalls = 1,
    timesteps = 10,
    ballStepInterval = 250,
    stepsToNextBall = 1,
    firingPosition = PositionVector:new(0, 0), -- This should be in grid units
    firingVelocity = PositionVector:new(0, 0), -- This should be in grid units
    g = -1 / 50000,
    newBalls = 0,
    nextFiringPosition = nil,
    hitBlocksTurn = 0,
}

-- Want internals to work with the positions of the grid I think, and then be
-- scaled up appropriately.

Location = {
    GRID = {},
    BELOW = {},
    OUT_OF_BOUNDS = {},
}

function FiringContext:new(grid_cols, grid_rows)
    FiringContext.__index = FiringContext
    setmetatable(FiringContext, {__index = Context})
    local o = Context:new()
    setmetatable(o, self)
    self.__index = self
    o.boundingBox = Box:new(0, grid_cols, 0, grid_rows)
    o.firingPosition = PositionVector:new(grid_cols / 2, grid_rows)
    return o
end

function FiringContext:update(grid)
    -- For a number of times per frame
    for i = 0, self.timesteps - 1 do
        -- -- print("")
        -- If more balls to be fired, and want a new one this timestep, create a new ball
        if self.firedBalls < self.targetBalls then
            -- print("new ball")
            self.stepsToNextBall = self.stepsToNextBall - 1
            if self.stepsToNextBall == 0 then
                self:fire()
                self.stepsToNextBall = self.ballStepInterval
            end
        end

        -- Take a timestep for all active balls
        self:propagateBalls()

        -- Handle collisions, by classifying locations and appropriately handling by location
        local toCheck = self.activeBalls
        local checkCount = self.activeCount
        while checkCount > 0 do
            -- print("check count", checkCount)
            local locations = self:determineLocations(toCheck, grid)
            self:handleBelow(locations[Location.BELOW])
            checkCount = self:handleOutOfBounds(locations[Location.OUT_OF_BOUNDS])
            -- print("out of bounds", checkCount)
            -- -- print("OOB count", checkCount)
            local gridCollisionCount = 0
            toCheck, gridCollisionCount = self:handleGrid(locations[Location.GRID])
            for id, ball in pairs(locations[Location.OUT_OF_BOUNDS]) do
                toCheck[id] = ball
            end
            -- -- print("Collision checks", gridCollisionCount)
            checkCount = checkCount + gridCollisionCount
            -- -- print(checkCount)
            -- Remove any non-valid blocks; really this should be done during
            -- collisions, but currently we don't do those in time order but in id
            -- order
            grid:cleanupElements()
        end

        -- Change velocity lmao
        self:updateVelocities()
    end
end

function FiringContext:fire()
    local newBall = Ball:new(self.firingPosition, self.firingVelocity)
    self.activeBalls[newBall:getId()] = newBall
    self.activeCount = self.activeCount + 1
    self.firedBalls = self.firedBalls + 1
end

function FiringContext:propagateBalls()
    for id, ball in pairs(self.activeBalls) do
        local oldPos = ball:getPos()
        -- -- print(oldPos.x, oldPos.y)
        local newPos = oldPos + ball:getVel() / self.timesteps
        -- -- print(newPos.x, newPos.y)
        ball:setPos(newPos.x, newPos.y)
        -- -- print("new pos:", newPos.x, newPos.y)
    end
end

function FiringContext:determineLocations(balls, grid)
    local locations = {
        [Location.GRID] = {},
        [Location.BELOW] = {},
        [Location.OUT_OF_BOUNDS] = {}
    }
    for id, ball in pairs(balls) do
        local ballPos = ball:getPos()
        local x = ballPos.x
        local y = ballPos.y
        local ballId = ball:getId()
        if self.boundingBox:inside(x, y) then
            -- print("Grid")
            locations[Location.GRID][ballId] = {
                block = grid:blockAt(math.floor(y), math.floor(x)),
                powerup = grid:powerupAt(math.floor(y), math.floor(x))
            }
        elseif self.boundingBox:below(y) then
            -- print("Below")
            locations[Location.BELOW][ballId] = ball
        else
            -- print("Out of Bounds")
            locations[Location.OUT_OF_BOUNDS][ballId] = ball
        end
    end
    return locations
end

function FiringContext:handleBelow(balls)
    for id, val in pairs(balls) do
        if self.nextFiringPosition == nil then
            local pos = self.activeBalls[id]:getPos()
            local bounds = self.boundingBox:getBounds()
            local x = pos.x
            if x < bounds.x0 then
                x = bounds.x0 + (bounds.x0 - x)
            elseif x > bounds.x1 then
                x = bounds.x1 + (bounds.x1 - x)
            end
            self.nextFiringPosition = PositionVector:new(x, bounds.y1)
        end
        self.activeBalls[id] = nil
        self.activeCount = self.activeCount - 1
    end
end

function FiringContext:handleOutOfBounds(balls)
    local count = 0
    for id, val in pairs(balls) do
        -- -- print("OOB", id, val)
        self.collider:handleCollision(self.activeBalls[id], self.boundingBox)
        count = count + 1
    end
    return count
end

function FiringContext:handleGrid(balls)
    -- print("handling grid")
    local collided = {}
    local count = 0
    -- print(balls, balls[1])
    for id, elements in pairs(balls) do
        -- print(id)
        if elements.block ~= nil then
            self.collider:handleCollision(self.activeBalls[id], elements.block)
            collided[id] = self.activeBalls[id]
            count = count + 1
            elements.block:decrement()
            if elements.block:getHitpoints() > -1 then
                self.hitBlocksTurn = self.hitBlocksTurn + 1
            end
        elseif elements.powerup ~= nil then
            local hit = elements.powerup:inside(self.activeBalls[id]:getPos())
            if hit then
                self.newBalls = self.newBalls + 1
            end
        end
    end
    return collided, count
end

function FiringContext:updateVelocities()
    for id, ball in pairs(self.activeBalls) do
        local oldVel = ball:getVel()
        local newVel = oldVel + PositionVector:new(0, -self.g / self.timesteps)
        ball:setVel(newVel.x, newVel.y)
        -- -- print("new vel:", newVel.x, newVel.y)
    end
end

function FiringContext:draw(adapter)
    for id, ball in pairs(self.activeBalls) do
        local viewportPos = adapter:gridToViewportCoordinate(ball.posNow.x, ball.posNow.y)
        love.graphics.circle("fill", viewportPos.x, viewportPos.y, 3)
    end
    if self.nextFiringPosition ~= nil then
        local viewportPos = adapter:gridToViewportCoordinate(self.nextFiringPosition.x, self.nextFiringPosition.y)
        love.graphics.circle("fill", viewportPos.x, viewportPos.y, 3)
    end
end

function FiringContext:isActive()
    return not ((self.activeCount == 0) and (self.firedBalls == self.targetBalls))
end

function FiringContext:reset()
    -- print(self.targetBalls, self.newBalls)
    self.targetBalls = self.targetBalls + self.newBalls
    self.firedBalls = 0
    self.activeCount = 0
    self.newBalls = 0
    self.stepsToNextBall = 1
    self.firingPosition = self.nextFiringPosition
    self.nextFiringPosition = nil
end

function FiringContext:setFiringPosition(pos)
    print("firing from:", pos.x, pos.y)
    self.firingPosition = pos
end

function FiringContext:setFiringDirection(directionVector)
    -- print(directionVector.x, directionVector.y)
    -- print("firing in the direction", directionVector.x, directionVector.y)
    self.firingVelocity = directionVector * 1 / 10
end

function FiringContext:getNextFiringPosition()
    return self.nextFiringPosition
end

function FiringContext:getHitBlockCount()
    local count = self.hitBlocksTurn
    self.hitBlocksTurn = 0
    return count
end

function FiringContext:getNumBalls()
    return self.targetBalls
end
