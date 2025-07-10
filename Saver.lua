require("Block")
require("Circle")
require("Grid")
require("io")

Saver = {}

function Saver:saveGrid(grid)
    local csvString = ""
    for i = 0, grid.rows do
        for j = 0, grid.columns - 1 do
            if grid.blocks[i][j] ~= nil then
                csvString = csvString .. grid.blocks[i][j]:getHitpoints() .. ","
            elseif grid.powerups[i][j] ~= nil then
                csvString = csvString .. "o,"
            else
                csvString = csvString .. "x,"
            end
        end
        csvString = csvString .. "\n"
    end

    -- probably should check whether we have write access first icl
    local path = love.filesystem.getAppdataDirectory()
    local f = assert(io.open(path .. "/Ballz/grid.csv", "w+"))
    f:write(csvString)
    f:close()
end
