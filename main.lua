require("Ball")
require("Box")
require("Collider")
require("PositionVector")

function love.load()
    Balls = {}
    local ballLeft = Ball:new(PositionVector:new(160.1, 125.1), PositionVector:new(0.05, -0.05))
    local ballRight = Ball:new(PositionVector:new(250.1, 125.1), PositionVector:new(-0.235, 0.01))
    local ballTop = Ball:new(PositionVector:new(200.1, 90.71), PositionVector:new(0.051, 0.1))
    local ballBottom = Ball:new(PositionVector:new(200.1, 160.1), PositionVector:new(0.1, -0.2))
    Balls[0] = ballLeft
    Balls[1] = ballRight
    Balls[2] = ballTop
    Balls[3] = ballBottom
    Blocks = {}
    local blockLeft = Box:new(175, 225, 150, 100)
    local blockRight = Box:new(275, 325, 150, 100)
    Blocks[0] = blockLeft
    Blocks[1] = blockRight
    DaCollider = Collider:new()
end

function love.update()
    local timesteps = 10
    g = 0.00012
    for t= 0, timesteps - 1 do
        for j=0,1 do
            local bounds = Blocks[j]:getBounds()
            for i=0,3 do
                local ball = Balls[i]
                ball:setPos(ball.posNow.x + ball.velNow.x / timesteps, ball.posNow.y + ball.velNow.y / timesteps)
                if (bounds.y0 > ball.posNow.y and ball.posNow.y > bounds.y1) and (bounds.x0 < ball.posNow.x and ball.posNow.x < bounds.x1) then
                    DaCollider:handleCollision(ball, Blocks[j])
                end
                ball:setVel(ball.velNow.x, ball.velNow.y + g / timesteps)
            end
        end
    end
end

function love.draw()
    love.graphics.setColor(0.8, 0.8, 0.8)

    for j=0,1 do
        local bounds = Blocks[j]:getBounds()
        love.graphics.rectangle("line", bounds.x0, bounds.y1, bounds.x1 - bounds.x0, bounds.y0 - bounds.y1)
    end

    for i=0,3 do
        local ball = Balls[i]
        love.graphics.circle("fill", ball.posNow.x, ball.posNow.y, 5)
    end
end
