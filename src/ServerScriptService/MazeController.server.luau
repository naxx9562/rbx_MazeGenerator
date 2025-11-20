local MazeManager = require(script.Parent.MazeManager)
local PathMapper = require(script.Parent.PathMapper)

local mazeManager = MazeManager.new()
local startClock = os.clock()

local function createExit() : nil
    local TURNS_PRIORITY = 1.5

    local startMap = PathMapper.createMap(
        Vector2.one,
        mazeManager.mapSize
    )

    local min = math.huge
    local result = nil

    local function compute(x : number, y : number) : nil
        if not startMap.isValid[x][y] then
            return
        end

        local length = startMap.distances[x][y] + startMap.turns[x][y] * TURNS_PRIORITY
        if min > length then
            result = Vector2.new(x, y)
            min = length
        end
    end

    for x=1, mazeManager.mapSize do
        compute(x, mazeManager.mapSize)
    end

    for y=1, mazeManager.mapSize do
        compute(mazeManager.mapSize, y)
    end

    if not result then
        error("There is no createExit result")
    end

    MazeManager:createDebugPart(result, Color3.new(0, 1, 0))
    print("Exit point created")
end

while true do -- use task.wait(any number) 4 realtime visualization
    local success = mazeManager:makeMove()
    if success then
        continue
    end

    print(`Maze generation complete in {math.floor((os.clock() - startClock) * 1000)}ms`)
    createExit()
    break
end