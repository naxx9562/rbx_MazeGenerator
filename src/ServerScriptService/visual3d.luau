local v3d = {}
local SIZE_CONST = 10

v3d.dir = {
    ["Up"] = Vector2.new(0, 0.5),
    ["Down"] = Vector2.new(0, -0.5),
    ["Left"] = Vector2.new(-0.5, 0),
    ["Right"] = Vector2.new(0.5, 0)
}

local walls : {{Part}} = {}
local function createWall(pos : Vector2, direction) : Part
    local part = Instance.new("Part")
    part.Anchored = true
    part.Size = Vector3.new(
        SIZE_CONST,
        SIZE_CONST * 0.5,
        SIZE_CONST * 0.1
    )

    if direction == v3d.dir.Up or direction == v3d.dir.Down then
        part.Orientation = Vector3.new(0, 90, 0)
    end
    pos += direction

    if not walls[pos.X] then
        walls[pos.X] = {}
    end
    walls[pos.X][pos.Y] = part

    part.Position = Vector3.new(
        pos.Y * SIZE_CONST,
        2,
        pos.X * SIZE_CONST
    )
    
    return part
end

function v3d.createCell(pos : Vector2) : Model
    local model = Instance.new("Model", workspace)

    if pos.X == 1 then
        createWall(pos, v3d.dir.Left).Parent = model
    end

    if pos.Y == 1 then
        createWall(pos, v3d.dir.Down).Parent = model
    end

    createWall(pos, v3d.dir.Up).Parent = model
    createWall(pos, v3d.dir.Right).Parent = model

    model.Name = `p:{pos.X};{pos.Y}`

    return model
end

function v3d.breakWall(pos : Vector2, direction : number)
    walls[pos.X][pos.Y]:Destroy()
end

return v3d