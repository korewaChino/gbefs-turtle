# This file contains the classes for the grid and turtle.
# An internal implementation, the user should not see this code.
from enum import Enum
from time import sleep

WAIT_TIME = 0.1

# A 2D grid class
# This class is used to represent a 2D grid
# The grid has an x and y coordinate for the turtle that will be inside it
class Grid:
    def __init__(self):
        self.x = 0
        self.y = 0

    def pos(self):
        return self.x, self.y


class Direction(Enum):
    NORTH = 0
    EAST = 1
    SOUTH = 2
    WEST = 3


# A turtle
# This class is used to represent a turtle that can move around the grid
# The turtle has a direction and a grid to represent its position
# The turtle can only turn left or right and move forward, you cannot strafe
# so you must turn the turtle in the direction you want to move
# The turtle starts facing north, but the user cannot see this
class Turtle:
    def __init__(self, grid):
        self.direction = Direction.NORTH
        self.grid = grid

    # Turn left
    def turn_left(self):
        print("Turning left")
        self.direction = Direction((self.direction.value - 1) % 4)
        sleep(WAIT_TIME)

    # Turn right
    def turn_right(self):
        print("Turning right")
        self.direction = Direction((self.direction.value + 1) % 4)
        sleep(WAIT_TIME)

    # Get current position
    def pos(self):
        return self.grid.pos()

    # Move forward
    def forward(self):
        print("Moving forward")
        if self.direction == Direction.NORTH:
            self.grid.y += 1
        elif self.direction == Direction.EAST:
            self.grid.x += 1
        elif self.direction == Direction.SOUTH:
            self.grid.y -= 1
        elif self.direction == Direction.WEST:
            self.grid.x -= 1
        
        sleep(WAIT_TIME)


# test
