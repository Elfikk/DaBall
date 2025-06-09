require("Ball")
require("Box")
require("Collider")
require("PositionVector")

function love.load()
    Balls = {}
    local ballLeft = Ball:new(PositionVector:new(160.1, 125.1), PositionVector:new(0.2, -0.1))
    local ballRight = Ball:new(PositionVector:new(230.1, 125.1), PositionVector:new(-0.2, -0.1))
    local ballTop = Ball:new(PositionVector:new(200.1, 95.1), PositionVector:new(0.1, 0.2))
    local ballBottom = Ball:new(PositionVector:new(200.1, 160.1), PositionVector:new(0.1, -0.2))
    Balls[0] = ballLeft
    Balls[1] = ballRight
    Balls[2] = ballTop
    Balls[3] = ballBottom
    DaBlock = Box:new(175, 225, 150, 100)
    DaCollider = Collider:new()
end

function love.update()
    local bounds = DaBlock:getBounds()
    for i=0,3 do
        local ball = Balls[i]
        ball:setPos(ball.posNow.x + ball.velNow.x, ball.posNow.y + ball.velNow.y)
        if (bounds.y0 > ball.posNow.y and ball.posNow.y > bounds.y1) and (bounds.x0 < ball.posNow.x and ball.posNow.x < bounds.x1) then
            DaCollider:handleCollision(ball, DaBlock)
        end
    end
end

function love.draw()
    local bounds = DaBlock:getBounds()
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("line", bounds.x0, bounds.y1, bounds.x1 - bounds.x0, bounds.y0 - bounds.y1)
    for i=0,3 do
        local ball = Balls[i]
        love.graphics.circle("fill", ball.posNow.x, ball.posNow.y, 5)
    end
end
