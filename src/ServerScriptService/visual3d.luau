local Visual3D = {}
Visual3D.walls = {}

--[[
PERFORMANCE TODO: Batch wall creation for better optimization
Current: All walls created upfront -> breakWall() destroys them during generation
Target: Calculate all wall positions -> create walls, without using breakWall()
Tradeoff: Lose real-time visualization (it worth in prod xd)
]]

Visual3D.SIZE_CONST = 15

Visual3D.DIRECTIONS = { -- converts between cell coordinates and wall coordinates
    UP = Vector2.new(0, 0.5),
    DOWN = Vector2.new(0, -0.5),
    LEFT = Vector2.new(-0.5, 0),
    RIGHT = Vector2.new(0.5, 0)
} -- .magnitude must be 0.5!!!

local function createWall(pos : Vector2, direction : Vector2) : Part
    local part = Instance.new("Part")
    part.Anchored = true
    part.Size = Vector3.new(Visual3D.SIZE_CONST, Visual3D.SIZE_CONST, Visual3D.SIZE_CONST * 0.1)
    part.CastShadow = false
	
    if direction == Visual3D.DIRECTIONS.UP or direction == Visual3D.DIRECTIONS.DOWN then
        part.Orientation = Vector3.new(0, 90, 0)
    end
    
    local wallPos = pos + direction
    part.Name = tostring(wallPos)
    
    if not Visual3D.walls[wallPos.X] then
        Visual3D.walls[wallPos.X] = {}
    end
    Visual3D.walls[wallPos.X][wallPos.Y] = part
    
    -- Position in 3D space (swap x/z cuz I was drunk)
    part.Position = Vector3.new(
        wallPos.Y * Visual3D.SIZE_CONST,
        Visual3D.SIZE_CONST / 2,
        wallPos.X * Visual3D.SIZE_CONST
    )
    
    return part
end

local wallFolder = Instance.new("Folder", workspace)
function Visual3D.createCell(pos : Vector2) : Model
    local model = Instance.new("Model")
    model.Name = `p:{pos.X};{pos.Y}`
    
    -- Create boundary walls
    if pos.X == 1 then
        createWall(pos, Visual3D.DIRECTIONS.LEFT).Parent = model
    end
    
    if pos.Y == 1 then
        createWall(pos, Visual3D.DIRECTIONS.DOWN).Parent = model
    end
    
    -- Always create top and right walls
    createWall(pos, Visual3D.DIRECTIONS.UP).Parent = model
    createWall(pos, Visual3D.DIRECTIONS.RIGHT).Parent = model
    
    model.Parent = wallFolder
    return model
end

function Visual3D.findWallByPos(wallSpacePos : Vector2) : Part
    return Visual3D.walls[wallSpacePos.X] and Visual3D.walls[wallSpacePos.X][wallSpacePos.Y]
end

function Visual3D.breakWall(wallSpacePos : Vector2) : nil
    local wall = Visual3D.findWallByPos(wallSpacePos)
    if wall then
        local par = wall.Parent
        wall:Destroy()
        Visual3D.walls[wallSpacePos.X][wallSpacePos.Y] = nil

        if #par:GetChildren() == 0 then
            par:Destroy()
        end
    end
end

return Visual3D