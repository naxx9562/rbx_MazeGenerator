local PathMapper = {}
local Visual3D = require(script.Parent.Visual3D)

function PathMapper.isWalkable(posA : Vector2, posB : Vector2) : boolean
    return Visual3D.findWallByPos((posA + posB) / 2) == nil
end

export type PathMap = {
    distances : {{number}},
    turns : {{number}},
    isValid : {{boolean}}
}

local directions = {
    Vector2.new(1, 0),  -- right
    Vector2.new(-1, 0), -- left
    Vector2.new(0, 1),  -- up
    Vector2.new(0, -1)  -- down
}

function PathMapper.createMap(startPos : Vector2, mapSize : number) : PathMap
    local result : PathMap = {distances = {}, turns = {}, isValid = {}}

    for x=1, mapSize do
        result.distances[x] = {}
        result.turns[x] = {}
        result.isValid[x] = {}

        for y=1, mapSize do
            result.distances[x][y] = math.huge
            result.turns[x][y] = math.huge
            result.isValid[x][y] = false
        end
    end

    local branches : {{
        pos : Vector2,
        lastDir : Vector2,
        distance : number,
        turns : number
    }} = {{
        pos = startPos, lastDir = nil, distance = 0, turns = 0
    }}

    while #branches > 0 do
        table.sort(branches, function(a, b)
            return a.distance < b.distance
        end)
        
        local current = table.remove(branches, 1)
        local curPos = current.pos
        local x, y = curPos.X, curPos.Y

        if x < 1 or x > mapSize or y < 1 or y > mapSize then
            continue
        end
        
        local hasBetterOrEqualPath = current.distance > result.distances[x][y] or
            (current.distance == result.distances[x][y] and current.turns >= result.turns[x][y])
        
        if hasBetterOrEqualPath then
            continue
        end
        
        result.distances[x][y] = current.distance
        result.turns[x][y] = current.turns
        result.isValid[x][y] = true
        
        for _, direction in directions do
            local newPos = curPos + direction
            local newX, newY = newPos.X, newPos.Y

            if newPos.X < 1 or newPos.X > mapSize or newPos.Y < 1 or newPos.Y > mapSize then
                continue
            end
            
            if not PathMapper.isWalkable(curPos, newPos) then
                continue
            end
            
            local turnCount = current.turns
            if current.lastDir and direction ~= current.lastDir then
                turnCount = turnCount + 1
            end
            
            local newDistance = current.distance + 1
            local shouldExplore = newDistance < result.distances[newX][newY]
                or (newDistance == result.distances[newX][newY]
                and turnCount < result.turns[newX][newY])
            
            if shouldExplore then
                table.insert(branches, {
                    pos = newPos,
                    lastDir = direction,
                    distance = newDistance,
                    turns = turnCount
                })
            end
        end
    end

    return result
end

return PathMapper