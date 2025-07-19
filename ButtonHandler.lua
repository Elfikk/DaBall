require("Button")
require("ShapeDrawer")

ButtonTypes = {
    PAUSE = {},
    RESTART = {},
    QUIT = {},
}

ButtonHandler = {
    visibleButtons = {},
    allButtons = {},
}

function ButtonHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Hardcoded layout is sad but good enough for now.
function ButtonHandler:makeButtons(x0, x1, y0, y1)
    local ds = (x1 - x0) / 50
    self.allButtons[ButtonTypes.PAUSE] = Button:new(
        x0,
        x0 + (x1 - x0)/3 - 2 * ds,
        y0,
        y1,
        "Pause",
        TextAlignment.CENTRE
    )
    self.allButtons[ButtonTypes.RESTART] = Button:new(
        x0 + (x1 - x0)/3 + ds,
        x0 + 2 * (x1 - x0)/3 - ds,
        y0,
        y1,
        "Restart",
        TextAlignment.CENTRE
    )
    self.allButtons[ButtonTypes.QUIT] = Button:new(
        x0 + 2 * (x1 - x0)/3 + 2 * ds,
        x1,
        y0,
        y1,
        "Quit",
        TextAlignment.CENTRE
    )
end

function ButtonHandler:draw()
    for enum, button in pairs(self.visibleButtons) do
        button:draw()
    end
end

function ButtonHandler:mousepressed(x, y, mouseButton, istouch, presses)
    for enum, button in pairs(self.visibleButtons) do
        if button:mousepressed(x, y, mouseButton, istouch, presses) then
            return enum
        end
    end
    return nil
end

function ButtonHandler:addButton(type, button, visible)
    self.allButtons[type] = button
    if visible then
        self.visibleButtons[type] = button
    end
end

function ButtonHandler:makeVisible(type)
    assert(self.visibleButtons[type] == nil, "Button is already visible.")
    assert(self.allButtons[type] ~= nil, "Button type does not exist but want to make visible.")
    self.visibleButtons[type] = self.allButtons[type]
end

function ButtonHandler:hide(type)
    assert(self.visibleButtons[type] ~= nil, "Button is already visible.")
    assert(self.allButtons[type] ~= nil, "Button type does not exist but want to be hidden.")
    self.visibleButtons[type] = nil
end

function ButtonHandler:setText(type, text)
    self.allButtons[type]:setText(text)
end

function ButtonHandler:restartReset()
    self.allButtons[ButtonTypes.PAUSE]:setText("Pause")
    self:hide(ButtonTypes.RESTART)
end
