require("Collider")
require("Context")
require("PositionVector")

FiringContext = {
    activeBalls = {},
    collider = Collider:new(),
    boundingBox = Box:new(0, 8, 0, 10),
    firedBalls = 0,
    activeCount = 0,
    targetBalls = 1,
    timesteps = 10,
    ballStepInterval = 15,
    stepsToNextBall = 1,
    firingPosition = PositionVector:new(0, 0), -- This should be in grid units
    firingVelocity = PositionVector:new(0, 1), -- This should be in grid units
    g = 0.001
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
    for i in 0, self.timesteps - 1 do
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
            local gridCollisionCount = 0
            toCheck, gridCollisionCount = self:handleGrid(locations[Location.GRID])
            for id, ball in locations[Location.OUT_OF_BOUNDS] do
                toCheck[id] = ball
            end
            checkCount = checkCount + gridCollisionCount
        end

        -- Remove any non-valid blocks; really this should be done during
        -- collisions, but currently we don't do those in time order but in id
        -- order
        grid:cleanupBlocks()

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
            locations[Location.GRID][ballId] = grid:getBlockAt(ballPos.x, ballPos.y)
        elseif self.boundingBox:below(ballPos.y) then
            locations[Location.BELOW][ballId] = ballId
        else
            locations[Location.OUT_OF_BOUNDS][ballId] = ballId
        end
    end
    return locations
end

function FiringContext:handleBelow(balls)
    for id, val in pairs(balls) do
        self.activeBalls.remove(id)
        self.activeCount = self.activeCount - 1
    end
end

function FiringContext:handleOutOfBounds(balls)
    local count = 0
    for id, val in pairs(balls) do
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
        end
    end
    return collided, count
end

function FiringContext:updateVelocities()
    for id, ball in pairs(self.activeBalls) do
        local oldVel = ball:getVel()
        local newVel = oldVel + PositionVector:new(0, -g / self.timesteps)
        ball:setPos(newVel.x, newVel.y)
    end
end

function FiringContext:draw()
    -- Draw the grid boxes
    -- Draw the balls
end

function FiringContext:isActive()
    return not ((self.activeCount == 0) and (self.firedBalls == self.targetBalls))
end
