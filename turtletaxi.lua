-- Cappy's Turtle taxi
-- A ComputerCraft script ported from the Python algorithm to taxi a turtle to a destination
-- +Z = North, -Z = South, +X = East, -X = West

if not turtle then
    printError("Requires a Turtle")
    return
end



coords = {
    x = nil,
    y = nil,
    z = nil,
}


dest = {
    x = nil,
    y = nil,
    z = nil,
}

-- get arguments

local args = { ... }

print("Arguments: ", table.concat(args, ", "))

if #args < 3 or #args > 3 then
    printError("Usage: taxi <x> <y> <z>")
    return
end

dest.x = tonumber(args[1])
dest.y = tonumber(args[2])
dest.z = tonumber(args[3])



facing = nil

-- Should be either x, y, or z, or nil
-- if nil, we should go to x, z then y
walking_priority = nil

-- Update direction assuming we are spinning clockwise
function spin_update_direction()
    if facing == "north" then
        facing = "east"
    elseif facing == "east" then
        facing = "south"
    elseif facing == "south" then
        facing = "west"
    elseif facing == "west" then
        facing = "north"
    end
end

function turn_direction(direction)
    while facing ~= direction do
        turtle.turnRight()
        spin_update_direction()
    end
end

function update_walk_priority()
    print("Updating walking priority...")
    if coords.x == dest.x and coords.z == dest.z then
        walking_priority = "y"
        return
    end
    -- check if our X and Z is equal to the destination
    if math.abs(coords.x - dest.x) < math.abs(coords.z - dest.z) then
        walking_priority = "x"
    else
        walking_priority = "z"
    end
end

walking_wait = 0.25

-- get the current position

function getPosition()
    -- print("Getting Position...")
    local x, y, z = gps.locate(5)
    -- error handle
    if not x then
        printError("Cannot determine position")
        return
    end
    -- print("Position: ", x, y, z)
    return { x = x, y = y, z = z }
end

-- Determine differences between 2 tables of coordinates to return a direction
-- @param table old_coords
-- @param table new_coords
-- @return string direction
function determine_delta_facing(old_coords, new_coords)
    -- print("old_coords: ", old_coords.x, old_coords.y, old_coords.z)
    -- print("new_coords: ", new_coords.x, new_coords.y, new_coords.z)


    local x_delta = new_coords.x - old_coords.x
    local z_delta = new_coords.z - old_coords.z

    print("X Delta: ", x_delta)
    print("Z Delta: ", z_delta)
    -- +Z = North, -Z = South, +X = East, -X = West

    if x_delta > 0 then
        return "east"
    elseif x_delta < 0 then
        return "west"
    elseif z_delta > 0 then
        return "south"
    elseif z_delta < 0 then
        return "north"
    else
        return nil
    end
end

-- Walk in the direction we are facing
-- alias for turtle.forward
-- @return void
function walk()
    local walk = turtle.forward()
    sleep(walking_wait)
    coords = getPosition()

    return walk
end

function are_we_there_yet()
    coords = getPosition()
    return coords.x == dest.x and coords.y == dest.y and coords.z == dest.z
end

-- Calibrate facing direction by attempting to move in any direction
-- Tries to move in any direction and then check coordinates to determine facing direction
-- If one of the values changes, then determine the facing direction based on the X and Z differences

-- @return string facing
function calibrate()
    print("Calibrating facing direction...")

    local old_coords = getPosition()
    print("Old Coords: ", old_coords.x, old_coords.y, old_coords.z)
    local moved = false
    local new_coords = nil
    -- Attempt to move in all directions if possible
    while not moved do
        sleep(walking_wait)
        if walk() then
            moved = true
            print("Moved forward!")
        else
            turtle.turnRight()
        end
        sleep(walking_wait)
    end

    new_coords = getPosition()

    -- print("New Coords: ", new_coords.x, new_coords.y, new_coords.z)
    local _facing = determine_delta_facing(old_coords, new_coords)
    print("Calibrated facing direction: ", _facing)

    print("Updating global coordinates...")


    -- Imperative update of global vars so we have the latest coordinates
    coords = new_coords
    return _facing
end

-- Turn to direction by taking the current facing direction, and the turning priority axis
-- Then look at our current coordinates and the destination coordinates, to determine which direction to turn
function turn_priority()
    -- +Z = North, -Z = South, +X = East, -X = West

    -- Check the walking priority

    if walking_priority == "x" then
        if coords.x < dest.x then
            turn_direction("east")
        else
            turn_direction("west")
        end
    elseif walking_priority == "z" then
        if coords.z < dest.z then
            turn_direction("south")
        else
            turn_direction("north")
        end
    else
        if coords.y < dest.y then
            turn_direction("up")
        else
            turn_direction("down")
        end
    end
end

function status()
    print("Destination: ", dest.x, dest.y, dest.z)
    print("Current Coords: ", coords.x, coords.y, coords.z)
    print("Facing: ", facing)
    print("Walking Priority: ", walking_priority)
    print("Are we there yet? ", are_we_there_yet())
end

-- Main loop
-- Taxi self to destination coordinates!
-- @param table dest
-- @return void
function taxi(dest)
    print("Taxiing to destination...")
    print("Destination: ", dest.x, dest.y, dest.z)

    status()

    while not are_we_there_yet() do
        status()
        sleep(walking_wait)
        update_walk_priority()
        turn_priority()
        walk()
    end
end

if facing == nil then
    facing = calibrate()
end

coords = getPosition()

-- print("Target Destination:", dest.x, dest.y, dest.z)

taxi(dest)
