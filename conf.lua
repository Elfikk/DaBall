function love.conf(t)
    -- metadata
    t.version = "11.5"

    -- window
    t.window.title = "BALLZ"
    t.window.width = 1200
    t.window.height = 900

    -- turn off needless modules
    t.modules.audio = false
    t.modules.data = false
    t.modules.image = false
    t.modules.joystick = false
    t.modules.keyboard = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.thread = false
    t.modules.touch = false
    t.modules.video = false
end