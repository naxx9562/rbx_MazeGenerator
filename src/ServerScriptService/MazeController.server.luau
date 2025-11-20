local MazeManager = require(script.Parent.MazeManager)

local mazeManager = MazeManager.new()
local startClock = os.clock()

while task.wait() do -- use task.wait(any number) 4 realtime visualization
    local success = mazeManager:makeMove()
    if not success then
        print(`Maze generation complete in {math.floor((os.clock() - startClock) * 1000)}ms`)
        break
    end
end