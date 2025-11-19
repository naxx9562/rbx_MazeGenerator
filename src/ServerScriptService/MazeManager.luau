local MazeManager = {}
MazeManager.__index = MazeManager

local Visual3D = require(script.Parent.Visual3D)

local MAP_SIZE = 35
local CONFUSION_CHANCE = 0.02 -- range = [0; 1)
-- creates transitions between cells that shouldn't have them
-- can create large open spaces, so it's best not to use large numbers

local MAX_TUNNEL_SIZE = 3

--[[
TODO: MAX_TUNNEL_SIZE doesn't work reliably on branch paths
Only affects initial path generation properly

BUG: Additional paths ignore tunnel length limits.
-> Unfixable due to the current branching implementation.

Future: Might add MIN_TUNNEL_SIZE if this ever becomes a real project
]]

function MazeManager.new()
    local self = setmetatable({}, MazeManager)
    
    self.mapSize = MAP_SIZE
    self.maxTunnelSize = MAX_TUNNEL_SIZE
    self.maze = {}
    self.path = {}
    self.turn = 0
    self.currentPosition = Vector2.new(1, 1)
    self.lastDirection = nil
    
    self:_initializeMaze()
    self:_setupDebugFolder()
    
    return self
end

function MazeManager:_initializeMaze() : nil
    for x = 1, self.mapSize do
        self.maze[x] = {}
        for y = 1, self.mapSize do
            local position = Vector2.new(x, y)
            Visual3D.createCell(position)
            
            self.maze[x][y] = {
                pos = position,
                wasVisited = false
            }
        end
    end
    
    -- Start position
    self.maze[1][1].wasVisited = true
    self.path[0] = { turns = {} }
end

function MazeManager:_setupDebugFolder() : nil
    if not workspace:FindFirstChild("DBG") then
        Instance.new("Folder", workspace).Name = "DBG"
    end
end

function MazeManager:isPositionValid(position : Vector2) : boolean
    return position.X > 0 and position.Y > 0
        and position.X <= self.mapSize and position.Y <= self.mapSize
end

function MazeManager:getAvailableMoves(pos : Vector2) : {{pos : Vector2, dir : number}}
    local availableMoves = {}
    local previousTurn = self.path[self.turn - 1]

    local function smartCheck(target, directionVector)
        local resultVector = target + directionVector * 2
        if previousTurn and resultVector == previousTurn.pos then
            return
        end

        if not self:isPositionValid(resultVector) then
            return
        end

        if not self.maze[resultVector.X][resultVector.Y].wasVisited or math.random() <= CONFUSION_CHANCE then
            table.insert(availableMoves, {
                cell = self.maze[resultVector.X][resultVector.Y],
                direction = directionVector
            })
        end
    end

    -- Clear debug visuals
    workspace.DBG:ClearAllChildren()

    for directionName, directionVector in pairs(Visual3D.DIRECTIONS) do
        -- Check straight path limit
        if directionVector == self.lastDirection then
            if self:getStraightPathLength(directionVector) >= self.maxTunnelSize then
                continue
            end
        end
        
        smartCheck(pos, directionVector)
    end

    return availableMoves
end

function MazeManager:getStraightPathLength(direction : number) : number
    for i = 0, self.maxTunnelSize do
        if not self.path[self.turn - i] or not table.find(self.path[self.turn - i].turns, direction) then
            return i+1
        end
    end
    return self.maxTunnelSize
end

function MazeManager:findBacktrackPoint() : (number, {{pos : Vector2, dir : number}})
    for previousTurn = self.turn - 1, 1, -1 do
        local position = self.path[previousTurn].pos
        local availableMoves = self:getAvailableMoves(position)
        
        if #availableMoves > 0 then
            return previousTurn, availableMoves
        end
    end
    return nil
end

function MazeManager:makeMove() : boolean
    local availableMoves = self:getAvailableMoves(self.currentPosition)

    if #availableMoves == 0 then
        local backtrackTurn, backtrackMoves = self:findBacktrackPoint()
        if not backtrackTurn then
            return false -- Maze generation complete
        end
        
        self.turn = backtrackTurn
        self.currentPosition = self.path[self.turn].pos
        availableMoves = backtrackMoves
    end

    self.turn += 1
    local selectedMove = availableMoves[math.random(1, #availableMoves)]
    
    Visual3D.breakWall(self.currentPosition + selectedMove.direction)
    
    if not self.path[self.turn] then
        self.path[self.turn] = { turns = {} }
    end
    
    self.lastDirection = selectedMove.direction
    self.path[self.turn].pos = self.currentPosition
    table.insert(self.path[self.turn].turns, self.lastDirection)
    
    selectedMove.cell.wasVisited = true
    self.currentPosition = selectedMove.cell.pos
    
    return true -- Move successful
end

function MazeManager:generateDebugPart(pos : Vector2, color : Color3)
    local part = Instance.new("Part")
    part.Size = Vector3.one * 3
    part.Position = Vector3.new(pos.Y * Visual3D.SIZE_CONST, 0, pos.X * Visual3D.SIZE_CONST)
    part.Anchored = true
    part.Color = color or Color3.new(0, 0, 1)
    part.Parent = workspace.DBG
    
    return part
end

return MazeManager