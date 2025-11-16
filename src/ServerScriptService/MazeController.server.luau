local v3d = require(script.Parent.visual3d)
local maze : {{pos : Vector2, cell : Model, wasIn : boolean}} = {}

local MAPSIZE = 30

for x=1, MAPSIZE do
    maze[x] = {}
    for y=1, MAPSIZE do
        local pp = Vector2.new(x, y)
        maze[x][y] = {
            pos = pp,
            cell = v3d.createCell(pp),
            wasIn = false
        }
    end
end
maze[1][1].wasIn = true

local curPos : Vector2 = Vector2.new(1,1)
local path = {}
local turn = 0

local function getConfusion()
    return math.random() <= 0.01
end

local function checkCell(pos : Vector2) : {{pos : Vector2, dir : number}} -- where to go
    local result = {}

    if pos.X > 1 and (not maze[pos.X-1][pos.Y].wasIn or getConfusion()) then
        table.insert(result, {cell = maze[pos.X-1][pos.Y], dir = v3d.dir.Right})
    end

    if pos.Y > 1 and (not maze[pos.X][pos.Y-1].wasIn or getConfusion()) then
        table.insert(result, {cell = maze[pos.X][pos.Y-1], dir = v3d.dir.Up})
    end

    if pos.X < MAPSIZE and (not maze[pos.X+1][pos.Y].wasIn or getConfusion()) then
        table.insert(result, {cell = maze[pos.X+1][pos.Y], dir = v3d.dir.Left})
    end

    if pos.Y < MAPSIZE and (not maze[pos.X][pos.Y+1].wasIn or getConfusion()) then
        table.insert(result, {cell = maze[pos.X][pos.Y+1], dir = v3d.dir.Down})
    end

    return result
end

local function isBackPossible()
    while turn > 1 do
        turn -= 1
        
        if path[turn].ables > 0 then
            return true
        end
    end
    return false
end

while task.wait() do
    local able = checkCell(curPos)
    if #able == 0 then
        if not isBackPossible() then
            break
        end
        curPos = path[turn].pos
        continue
    end
    turn += 1

    local nextCell = able[math.random(1, #able)]
    v3d.breakWall(nextCell.cell.pos + nextCell.dir)
    path[turn] = {ables = #able-1, pos = curPos}

    -- DBG
    local pp = Instance.new("Part", workspace)
    local e = nextCell.cell.pos * 10
    pp.Position = Vector3.new(e.Y, 0, e.X)
    pp.Anchored = true
    pp.Size = Vector3.one * 3
    pp.Color = Color3.new(0, 0, 1)
    -- DBG END

    nextCell.cell.wasIn = true
    curPos = nextCell.cell.pos
end