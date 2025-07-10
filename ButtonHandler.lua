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
