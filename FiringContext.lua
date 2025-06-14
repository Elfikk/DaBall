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
    targetBalls = 5,
    timesteps = 10,
    ballStepInterval = 500,
    stepsToNextBall = 1,
    firingPosition = PositionVector:new(2, 10), -- This should be in grid units
    firingVelocity = PositionVector:new(0.2, -.2) / 10, -- This should be in grid units
    g = -0.001 / 100
}

-- Want internals to work with the positions of the grid I think, and then be
-- scaled up appropriately.

Location = {
    GRID = {},
    BELOW = {},
    OUT_OF_BOUNDS = {},
}

function FiringContext:new()
    FiringContext.__index = FiringContext
    setmetatable(FiringContext, {__index = Context})
    local o = Context:new()
    setmetatable(o, self)
    self.__index = self
    return o
end

function FiringContext:update(grid)
    -- For a number of times per frame
    for i = 0, self.timesteps - 1 do
        -- print("")
        -- print("timestep", i)
        -- If more balls to be fired, and want a new one this timestep, create a new ball
        if self.firedBalls < self.targetBalls then
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
            local locations = self:determineLocations(toCheck, grid)
            self:handleBelow(locations[Location.BELOW])
            checkCount = self:handleOutOfBounds(locations[Location.OUT_OF_BOUNDS])
            -- print("OOB count", checkCount)
            local gridCollisionCount = 0
            toCheck, gridCollisionCount = self:handleGrid(locations[Location.GRID])
            for id, ball in pairs(locations[Location.OUT_OF_BOUNDS]) do
                toCheck[id] = ball
            end
            -- print("Collision checks", gridCollisionCount)
            checkCount = checkCount + gridCollisionCount
            -- print(checkCount)
            -- Remove any non-valid blocks; really this should be done during
            -- collisions, but currently we don't do those in time order but in id
            -- order
            grid:cleanupBlocks()
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
        local newPos = oldPos + ball:getVel() / self.timesteps
        ball:setPos(newPos.x, newPos.y)
        -- print("new pos:", newPos.x, newPos.y)
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
        local ballId = ball:getId()
        if self.boundingBox:inside(ballPos.x, ballPos.y) then
            locations[Location.GRID][ballId] = grid:blockAt(math.floor(ballPos.y), math.floor(ballPos.x))
        elseif self.boundingBox:below(ballPos.y) then
            locations[Location.BELOW][ballId] = ball
        else
            locations[Location.OUT_OF_BOUNDS][ballId] = ball
        end
    end
    return locations
end

function FiringContext:handleBelow(balls)
    for id, val in pairs(balls) do
        self.activeBalls[id] = nil
        self.activeCount = self.activeCount - 1
    end
end

function FiringContext:handleOutOfBounds(balls)
    local count = 0
    for id, val in pairs(balls) do
        -- print("OOB", id, val)
        self.collider:handleCollision(self.activeBalls[id], self.boundingBox)
        count = count + 1
    end
    return count
end

function FiringContext:handleGrid(balls)
    local collided = {}
    local count = 0
    for id, box in pairs(balls) do
        if box ~= nil then
            self.collider:handleCollision(self.activeBalls[id], box)
            collided[id] = self.activeBalls[id]
            count = count + 1
            box:decrement()
        end
    end
    return collided, count
end

function FiringContext:updateVelocities()
    for id, ball in pairs(self.activeBalls) do
        local oldVel = ball:getVel()
        local newVel = oldVel + PositionVector:new(0, -self.g / self.timesteps)
        ball:setVel(newVel.x, newVel.y)
        -- print("new vel:", newVel.x, newVel.y)
    end
end

function FiringContext:draw(grid)
    grid:draw()
    for id, ball in pairs(self.activeBalls) do
        love.graphics.circle("fill", ball.posNow.x * SF, ball.posNow.y * SF, 5)
    end
end

function FiringContext:isActive()
    return not ((self.activeCount == 0) and (self.firedBalls == self.targetBalls))
end
