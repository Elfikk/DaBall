require("bit")

TextAlignment = {
    CENTRE = 0x1,
    LEFT = 0x2,
    RIGHT = 0x4,
    TOP = 0x8,
    BOTTOM = 0x10,
}

ShapeDrawer = {}

function ShapeDrawer:drawRectangle(x, y, width, height, palette, text, textAlignment)
    assert(palette ~= nil, "Palette was not a valid table when drawing rectangle.")
    if palette.fill ~= nil then
        love.graphics.setColor(palette.fill.r, palette.fill.g, palette.fill.b)
        love.graphics.rectangle("fill", x, y, width, height)
    end
    if palette.outline ~= nil then
        love.graphics.setColor(palette.outline.r, palette.outline.g, palette.outline.b)
        love.graphics.rectangle("line", x, y, width, height)
    end
    if text ~= nil then
        if palette.text == nil then
            return
        end
        self:drawText(x, y, width, height, text, textAlignment, palette.text)
    end
end

function ShapeDrawer:drawCircle(x, y, r, palette, text, textAlignment)
    if palette.fill ~= nil then
        love.graphics.setColor(palette.fill.r, palette.fill.g, palette.fill.b)
        love.graphics.circle("fill", x, y, r)
    end
    if palette.outline ~= nil then
        love.graphics.setColor(palette.outline.r, palette.outline.g, palette.outline.b)
        love.graphics.circle("line", x, y, r)
    end
    if text ~= nil then
        if palette.text == nil then
            return
        end
        self:drawText(x - r, y - r, 2 * r, 2 * r, text, textAlignment, palette.text)
    end
end

function ShapeDrawer:drawText(x, y, boundingWidth, boundingHeight, text, alignment, colour)
    assert(text ~= nil, "Passed no text to draw")
    local offsetX = 0
    local offsetY = 0
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight(text)
    if (bit.band(alignment,TextAlignment.CENTRE) == 1) then
        offsetX = (boundingWidth - textWidth) / 2
        offsetY = (boundingHeight - textHeight) / 2
    end
    if (bit.band(alignment,TextAlignment.LEFT) == 1) then
        offsetX = 0
    elseif (bit.band(alignment,TextAlignment.RIGHT) == 1) then
        offsetX = boundingWidth - textWidth
    end
    if (bit.band(alignment,TextAlignment.TOP) == 1) then
        offsetY = 0
    elseif (bit.band(alignment,TextAlignment.BOTTOM) == 1) then
        offsetY = boundingHeight - textHeight
    end
    love.graphics.setColor(colour.r, colour.g, colour.b)
    love.graphics.print(text, x + offsetX, y + offsetY)
end
