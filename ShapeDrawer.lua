require("bit")

TextAlignment = {
    CENTRE = 0x1,
    LEFT = 0x2,
    RIGHT = 0x4,
    TOP = 0x8,
    BOTTOM = 0x10,
    OUTSIDE = 0x20,
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

-- TODO : Support Text on a Line?
function ShapeDrawer:drawLine(x0, y0, x1, y1, palette)
    assert(palette ~= nil, "Palette was not a valid table when drawing line.")
    if palette.outline ~= nil then
        love.graphics.setColor(palette.outline.r, palette.outline.g, palette.outline.b)
        love.graphics.line(x0, y0, x1, y1)
    end
end

function ShapeDrawer:drawText(x, y, boundingWidth, boundingHeight, text, alignment, colour)
    assert(text ~= nil, "Passed no text to draw")
    local offsetX, offsetY = 0, 0
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight(text)
    if (bit.band(alignment,TextAlignment.OUTSIDE) == 0) then
        offsetX, offsetY = self:insideAlignments(alignment, textWidth, textHeight, boundingWidth, boundingHeight)
    else
        offsetX, offsetY = self:outsideAlignments(alignment, textWidth, textHeight, boundingWidth, boundingHeight)
    end
    love.graphics.setColor(colour.r, colour.g, colour.b)
    love.graphics.print(text, x + offsetX, y + offsetY)
end

function ShapeDrawer:insideAlignments(alignment, textWidth, textHeight, boundingWidth, boundingHeight)
    local offsetX = 0
    local offsetY = 0
    if (bit.band(alignment,TextAlignment.CENTRE) ~= 0) then
        offsetX = (boundingWidth - textWidth) / 2
        offsetY = (boundingHeight - textHeight) / 2
    end
    if (bit.band(alignment,TextAlignment.LEFT) ~= 0) then
        offsetX = 0
    elseif (bit.band(alignment,TextAlignment.RIGHT) ~= 0) then
        offsetX = boundingWidth - textWidth
    end
    if (bit.band(alignment,TextAlignment.TOP) ~= 0) then
        offsetY = 0
    elseif (bit.band(alignment,TextAlignment.BOTTOM) ~= 0) then
        offsetY = boundingHeight - textHeight
    end
    return offsetX, offsetY
end

function ShapeDrawer:outsideAlignments(alignment, textWidth, textHeight, boundingWidth, boundingHeight)
    local offsetX = 0
    local offsetY = 0
    if (bit.band(alignment,TextAlignment.CENTRE) ~= 0) then
        offsetX = (boundingWidth - textWidth) / 2
        offsetY = (boundingHeight - textHeight) / 2
    end
    if (bit.band(alignment,TextAlignment.LEFT) ~= 0) then
        offsetX = - textWidth
    elseif (bit.band(alignment,TextAlignment.RIGHT) ~= 0) then
        offsetX = boundingWidth + textWidth
    end
    if (bit.band(alignment,TextAlignment.TOP) ~= 0) then
        offsetY = - textHeight
    elseif (bit.band(alignment,TextAlignment.BOTTOM) ~= 0) then
        offsetY = boundingHeight
    end
    return offsetX, offsetY
end
