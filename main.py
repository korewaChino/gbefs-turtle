from typing import Optional
import grid

# Determine the turtle's direction without accessing the turtle's direction attribute directly
# This works by attempting to walk forward and delta the position to determine the direction.
# This implementation specifically uses a simple greedy BeFS algorithm to determine where the turtle should go.
# The turtle can only move forward, turn left or right, and determine its position based on the grid.

# We assume that the entire grid is an empty 2D plane with no obstacles, and the turtle can move freely.

# Additional note: The rotation operation in turn_to() can be optimized further by allowing it to turn counter-clockwise, but
# for simplicity, we have chosen to turn the turtle clockwise only to keep the implementation simple.

# +X is east, -X is west, +Y is north, -Y is south

def determine_direction(turtle):
    """
    Calibrate the turtle by attempting to move forward and determine the direction
    by calculating the delta of the position before and after moving forward.
    This function will return the direction the turtle is facing.

    It moves the turtle forward by one unit, and then compares the position before and after moving forward
    to determine the direction the turtle is facing.
    """
    x, y = turtle.pos()
    turtle.forward()
    dx, dy = turtle.pos()
    print(dx, dy)
    turtle.grid.x = x
    turtle.grid.y = y
    if dx - x == 1:
        return grid.Direction.EAST
    elif dx - x == -1:
        return grid.Direction.WEST
    elif dy - y == 1:
        return grid.Direction.NORTH
    elif dy - y == -1:
        return grid.Direction.SOUTH
    else:
        return None
    

# global variable to contain the direction
DIRECTION: Optional[grid.Direction] = None

# Destination to reach
DEST = (9, -18)

# can be x or y
COORD_PRIORITY = "" # this will be used to determine the priority of the coordinates


# Now, how do we pathfind to the destination with this information?
# We can't use the turtle's direction attribute, so we have to use the global DIRECTION variable
# The only way we can move the turtle is by turning it and moving it forward

# Turn the turtle to face a specific direction
def turn_to(turtle: grid.Turtle, direction: grid.Direction):
    """
    Turn the turtle to face a specific direction

    Keep turning the turtle to the right until it faces the desired direction.
    We also imperatively update the global DIRECTION variable to the desired direction to keep track of the turtle's direction
    without having to re-calibrate it.
    """
    # We can only use the global DIRECTION variable here!!
    global DIRECTION

    # lets copy the direction to a local variable, convert into ONLY the enum value

    if DIRECTION == direction:
        return
    if DIRECTION is None:
        return
    


    
    # Turn the turtle to the right until it faces the direction
    while DIRECTION != direction:
        turtle.turn_right()
        real_direction = turtle.direction # this is the real direction
        print(f"real direction: {real_direction}, desired direction: {direction}")

        # Calculate the direction ourselves
        DIRECTION = grid.Direction((DIRECTION.value + 1) % 4)

    print("Turtle is facing the right direction")


# Calculate the position priority based on the destination
def calc_priority(turtle: grid.Turtle):
    """
    Calculate the priority of the coordinates based on the destination

    This function will calculate the priority of the coordinates based on the destination.

    The priority is determined by the absolute difference between the destination and the current position,
    a simple implementation of a greedy BeFS algorithm.
    """
    global COORD_PRIORITY
    global DEST

    x, y = turtle.pos()

    dx, dy = DEST

    if abs(dx - x) > abs(dy - y):
        COORD_PRIORITY = "x"
    else:
        COORD_PRIORITY = "y"

    print(f"Priority is {COORD_PRIORITY}")

    return COORD_PRIORITY


# Now calculate the direction to turn to based on the coord priority, and the destination
def calc_direction(turtle: grid.Turtle):
    """
    Calculate the direction to turn to based on the coordinate priority and the destination

    Makes use of the information provided by the above BeFS algorithm to determine which direction to turn to
    based on the priority of the coordinates and then where the destination is.
    
    """
    global COORD_PRIORITY
    global DEST

    x, y = turtle.pos()

    dx, dy = DEST

    if COORD_PRIORITY == "x":
        if dx > x:
            return grid.Direction.EAST
        elif dx < x:
            return grid.Direction.WEST
    elif COORD_PRIORITY == "y":
        if dy > y:
            return grid.Direction.NORTH
        elif dy < y:
            return grid.Direction.SOUTH

    return None

# Taxi the turtle to the destination using the information we have
def taxi(turtle: grid.Turtle):

    """
    Taxi the turtle to the destination using the information we have

    This is the main loop of this program, where the turtle will taxi to the destination based on the information we have
    """
    global DEST
    global DIRECTION
    global COORD_PRIORITY

    

    while turtle.pos() != DEST:
        COORD_PRIORITY = calc_priority(turtle)
        direction = calc_direction(turtle)
        turn_to(turtle, direction) # type: ignore
        turtle.forward()
        print(turtle.pos())

    print("Turtle has reached the destination")

# Main function
def main():
    print("Determining the turtle's direction")
    g = grid.Grid()
    t = grid.Turtle(g)
    global DIRECTION
    DIRECTION = determine_direction(t)

    print("The turtle is facing", DIRECTION)
    print(t.pos())

    print("Turning the turtle to face the destination")

    turn_to(t, direction=grid.Direction.SOUTH)
    print("turning west")
    turn_to(t, direction=grid.Direction.WEST)
    print(DIRECTION)

    print("Taxiing the turtle to the destination")
    taxi(t)

    





if __name__ == "__main__":
    main()

