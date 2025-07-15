require("Palettes")
require("ShapeDrawer")

Button = {
    palette = CurrentTheme.counterColours,
    id = 0,
    text = nil,
    textAlignment = 0,
}

function Button:new(x0, x1, y0, y1, text, textAlignment)
    Button.__index = Button
    setmetatable(Button, {__index = Box})
    local o = Box:new(x0, x1, y0, y1)
    setmetatable(o, Button)
    o.id = Button.id
    Button.id = Button.id + 1
    o.text = text
    o.textAlignment = textAlignment
    return o
end

function Button:mousepressed(x, y, button, istouch, presses)
    return self:inside(x, y)
end

function Button:draw()
    local bounds = self.bounds
    ShapeDrawer:drawRectangle(
        bounds.x0,
        bounds.y0,
        bounds.x1 - bounds.x0,
        bounds.y1 - bounds.y0,
        self.palette,
        self.text,
        self.textAlignment
    )
end

function Button:setText(text)
    self.text = text
end
