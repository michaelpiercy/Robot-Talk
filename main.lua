print("-- Caleb's robot")
_w = display.actualContentWidth
_h = display.actualContentHeight

local Decision = require("Definitions.responses")

-- Display robot picture
local robot = display.newImageRect( "robot.png", 135, 306)
robot.x = _w/2
robot.y = _h - 310/2
robot.speechIndex = 1
robot.typeSpeed = 30
robot.speechBubble = display.newGroup()
robot.instructions = {
   "Loading... Caleb's Robot",
   "Robot Sequence Initiated...",
   Decision:new():greeting(),
   Decision:new():randomAnswer(),
   "My answer is... " .. Decision:new():affirmation(),
   "My answer is... " .. Decision:new():negative(),
   Decision:new():goodbye(),
}

-- Initiate the speech function
robot.framework = require("Framework.functions")
robot.framework.displayData(robot)

-- Tap the robot to initate the speech function
robot:addEventListener("tap", robot.framework.speak)
