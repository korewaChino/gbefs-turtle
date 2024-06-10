-- Greedy BeFS taxi driver for ComputerCraft

function empty(table)
    for _, value in pairs(table) do
        if value ~= nil then
            return false
        end
    end
    return true
end

-- Const for directions

walking_wait = 0.5

-- Directions
-- So turning left is just adding 1 to the current direction
-- and turning right is subtracting 1
North, West, South, East, Up, Down = 0, 1, 2, 3, 4, 5
local shortNames = {[North] = "N", [West] = "W", [South] = "S",
                                    [East] = "E", [Up] = "U", [Down] = "D" }


local deltas = {
    [North] = {x = 0, y = 0, z = -1},
    [West] = {x = -1, y = 0, z = 0},
    [South] = {x = 0, y = 0, z = 1},
    [East] = {x = 1, y = 0, z = 0},
    [Up] = {x = 0, y = 1, z = 0},
    [Down] = {x = 0, y = -1, z = 0},
}

pos = {
    x,
    y,
    z,
}

local dest = {
    x,
    y,
    z
}

local args = { ... }

print("Arguments: ", table.concat(args, ", "))

if #args < 3 or #args > 3 then
    printError("Usage: taxi <x> <y> <z>")
    return
end

dest.x = tonumber(args[1])
dest.y = tonumber(args[2])
dest.z = tonumber(args[3])


local facing

function get_position()
    local x, y, z = gps.locate(5)
    return {
        x = x,
        y = y,
        z = z,
    }
end

pos = get_position()

-- Walk in the direction we are facing
-- alias for turtle.forward
--
-- @return boolean success, [string] error
function forward()
    sleep(walking_wait)
    while not turtle.forward() do
        sleep(walking_wait)
        if turtle.detect() then
            if turtle.dig() then
                print("Digging forward")
            else
                -- keep trying
                print("Can't dig forward!")
            end
        else
            print("Can't move!, waiting for obstruction to clear")
        end
    end
    pos = get_position()
    sleep(walking_wait)
end

function up()
    sleep(walking_wait)
    while not turtle.up() do
        sleep(walking_wait)
        if turtle.detectUp() then
            if turtle.digUp() then
                print("Digging up")
            else
                -- keep trying
                print("Can't dig up!")
            end
        else
            print("Can't move up!, waiting for obstruction to clear")
        end
    end
    pos = get_position()
    sleep(walking_wait)
end

function down()
    sleep(walking_wait)
    while not turtle.down() do
        sleep(walking_wait)
        if turtle.detectDown() then
            if turtle.digDown() then
                print("Digging down")
            else
                -- keep trying
                print("Can't dig down!")
            end
        else
            print("Can't move down!, waiting for obstruction to clear")
        end
    end
    sleep(walking_wait)
end

function turnLeft()
    print("Turning left")
    turtle.turnLeft()
    facing = (facing + 1) % 4
end

function turnRight()
    print("Turning right")
    turtle.turnRight()
    facing = (facing - 1) % 4
end

function turnAround()
    print("Turning around")
    turtle.turnRight()
    turtle.turnRight()
    facing = (facing + 2) % 4
end

function turnTo(newFacing)
    print("Turning to ", shortNames[newFacing])
    while facing ~= newFacing do
        turnRight()
    end
end

-- Calibrate the facing direction by attempting to move in any direction
-- and comparing the delta to enum
function calibrate()
    local old_pos = get_position()

    forward()
    local new_pos = get_position()

    if new_pos.x > old_pos.x then
        facing = East
    elseif new_pos.x < old_pos.x then
        facing = West
    elseif new_pos.z > old_pos.z then
        facing = South
    elseif new_pos.z < old_pos.z then
        facing = North
    else
        print("Can't determine facing direction!")
    end

end

local axis_priority

function determine_axis()
    if math.abs(dest.x - pos.x) > math.abs(dest.z - pos.z) then
        axis_priority = "x"
    else
        axis_priority = "z"
    end
end

function status()
    print("Position: ", pos.x, pos.y, pos.z)
    print("Facing: ", shortNames[facing])
    print("Destination: ", dest.x, dest.y, dest.z)
    print("Axis Priority: ", axis_priority)

end

function taxi()
    calibrate()
    print("Calibrated facing: ", shortNames[facing])
    print("Destination: ", dest.x, dest.y, dest.z)
    print("Axis priority: ", axis_priority)
    pos = get_position()
    status()
    while pos.x ~= dest.x or pos.z ~= dest.z or pos.y ~= dest.y do
        pos = get_position()
        status()
        -- Keep updating the axis priority
        determine_axis()

        if pos.x == dest.x and pos.z == dest.z then
            if pos.y < dest.y then
                up()
            elseif pos.y > dest.y then
                down()
            end
        end

        if axis_priority == "x" then
            if pos.x < dest.x then
                turnTo(East)
                forward()

            elseif pos.x > dest.x then
                turnTo(West)
                forward()
            end
        end

        if axis_priority == "z" then
            if pos.z < dest.z then
                turnTo(South)
                forward()
            elseif pos.z > dest.z then
                turnTo(North)
                forward()
            end
        end
    end

    print("Arrived at destination!")
end

taxi()
