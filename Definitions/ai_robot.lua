-- AI Robot for Caleb's AI Assistant
-- Solar2D compatible implementation

local AIRobot = {}

-- Robot state
local robotState = {
    mood = "neutral",
    energy = 100,
    personality = "helpful",
    currentAnimation = "idle",
    isThinking = false,
    lastInteraction = 0
}

-- Animation states
local animations = {
    idle = {
        duration = 2000,
        scale = {1.0, 1.05, 1.0},
        alpha = {1.0, 1.0, 1.0}
    },
    thinking = {
        duration = 1000,
        scale = {1.0, 1.1, 1.0},
        alpha = {1.0, 0.8, 1.0}
    },
    excited = {
        duration = 500,
        scale = {1.0, 1.2, 1.0},
        alpha = {1.0, 1.0, 1.0}
    },
    sad = {
        duration = 1500,
        scale = {1.0, 0.9, 1.0},
        alpha = {1.0, 0.7, 1.0}
    }
}

-- Personality responses
local personalityResponses = {
    helpful = {
        thinking = "Let me think about that...",
        processing = "Processing your request...",
        success = "I'm happy to help!",
        confusion = "I'm not quite sure about that. Could you clarify?"
    },
    friendly = {
        thinking = "Hmm, interesting question!",
        processing = "Working on it...",
        success = "Great! Here's what I found.",
        confusion = "That's a bit unclear to me. Can you explain more?"
    },
    professional = {
        thinking = "Analyzing your query...",
        processing = "Processing information...",
        success = "Task completed successfully.",
        confusion = "Request unclear. Please provide more details."
    }
}

-- Create new AI Robot instance
function AIRobot:new()
    local robot = {}
    setmetatable(robot, { __index = AIRobot })
    
    robot.sprite = nil
    robot.animationTimer = nil
    robot.personality = "helpful"
    robot.personalityIndicator = nil
    robot.energyBar = nil
    robot.moodIndicator = nil
    
    return robot
end

-- Create robot sprite
function AIRobot:createSprite()
    local _w = display.actualContentWidth
    local _h = display.actualContentHeight
    
    -- Create robot sprite
    self.sprite = display.newImageRect("robot.png", 135, 306)
    self.sprite.x = _w/2
    self.sprite.y = _h - 310/2
    
    -- Add personality indicator
    self.personalityIndicator = display.newCircle(_w/2 + 80, _h - 350, 15)
    self.personalityIndicator:setFillColor(0.2, 0.8, 0.2, 0.8)
    
    -- Add energy bar
    self.energyBar = display.newRoundedRect(_w/2, _h - 380, 100, 8, 4)
    self.energyBar:setFillColor(0.2, 0.8, 0.2, 0.8)
    self.energyBar:setStrokeColor(0.1, 0.4, 0.1, 1)
    self.energyBar.strokeWidth = 1
    
    -- Add mood indicator
    self.moodIndicator = display.newText({
        text = "😊",
        x = _w/2 + 120,
        y = _h - 350,
        font = native.systemFont,
        fontSize = 20
    })
    
    self:startIdleAnimation()
    return self.sprite
end

-- Start idle animation
function AIRobot:startIdleAnimation()
    if self.animationTimer then
        timer.cancel(self.animationTimer)
    end
    
    local anim = animations.idle
    self.animationTimer = timer.performWithDelay(anim.duration, function()
        if self.sprite then
            transition.to(self.sprite, {
                time = anim.duration/2,
                xScale = anim.scale[2],
                yScale = anim.scale[2],
                onComplete = function()
                    if self.sprite then
                        transition.to(self.sprite, {
                            time = anim.duration/2,
                            xScale = anim.scale[1],
                            yScale = anim.scale[1]
                        })
                    end
                end
            })
        end
    end, -1)
end

-- Play animation
function AIRobot:playAnimation(animationName)
    if self.animationTimer then
        timer.cancel(self.animationTimer)
    end
    
    local anim = animations[animationName]
    if not anim or not self.sprite then return end
    
    robotState.currentAnimation = animationName
    
    -- Play the animation
    transition.to(self.sprite, {
        time = anim.duration/2,
        xScale = anim.scale[2],
        yScale = anim.scale[2],
        alpha = anim.alpha[2],
        onComplete = function()
            if self.sprite then
                transition.to(self.sprite, {
                    time = anim.duration/2,
                    xScale = anim.scale[1],
                    yScale = anim.scale[1],
                    alpha = anim.alpha[1],
                    onComplete = function()
                        if animationName ~= "idle" then
                            self:startIdleAnimation()
                        end
                    end
                })
            end
        end
    })
    
    -- Update personality indicator color based on mood
    local colors = {
        neutral = {0.2, 0.8, 0.2, 0.8},
        excited = {0.8, 0.2, 0.2, 0.8},
        sad = {0.2, 0.2, 0.8, 0.8},
        thinking = {0.8, 0.8, 0.2, 0.8}
    }
    
    if colors[animationName] and self.personalityIndicator then
        self.personalityIndicator:setFillColor(unpack(colors[animationName]))
    end
end

-- Update mood
function AIRobot:updateMood(sentiment)
    robotState.mood = sentiment
    
    local moodEmojis = {
        positive = "😊",
        negative = "😔",
        neutral = "😐",
        excited = "🤖",
        thinking = "🤔"
    }
    
    if self.moodIndicator and moodEmojis[sentiment] then
        self.moodIndicator.text = moodEmojis[sentiment]
    end
    
    -- Update energy based on interaction
    robotState.energy = math.min(100, robotState.energy + 5)
    self:updateEnergyBar()
end

-- Update energy bar
function AIRobot:updateEnergyBar()
    if self.energyBar then
        local energyPercent = robotState.energy / 100
        local energyColors = {
            {0.2, 0.8, 0.2, 0.8}, -- Green (high energy)
            {0.8, 0.8, 0.2, 0.8}, -- Yellow (medium energy)
            {0.8, 0.2, 0.2, 0.8}  -- Red (low energy)
        }
        
        local colorIndex = 1
        if energyPercent < 0.5 then
            colorIndex = 3
        elseif energyPercent < 0.8 then
            colorIndex = 2
        end
        
        self.energyBar:setFillColor(unpack(energyColors[colorIndex]))
    end
end

-- Process input
function AIRobot:processInput(input)
    if not input then return "neutral" end
    
    -- Analyze sentiment
    local sentiment = "neutral"
    local inputLower = string.lower(input)
    
    if inputLower:find("great") or inputLower:find("awesome") or inputLower:find("love") then
        sentiment = "positive"
    elseif inputLower:find("bad") or inputLower:find("terrible") or inputLower:find("hate") then
        sentiment = "negative"
    elseif inputLower:find("think") or inputLower:find("how") or inputLower:find("what") then
        sentiment = "thinking"
    end
    
    -- Update robot state
    self:updateMood(sentiment)
    
    -- Play appropriate animation
    if sentiment == "positive" then
        self:playAnimation("excited")
    elseif sentiment == "negative" then
        self:playAnimation("sad")
    elseif sentiment == "thinking" then
        self:playAnimation("thinking")
    else
        self:playAnimation("idle")
    end
    
    -- Update interaction time
    robotState.lastInteraction = os.time()
    
    return sentiment
end

-- Get personality response
function AIRobot:getPersonalityResponse(responseType)
    local responses = personalityResponses[self.personality]
    return responses[responseType] or "Processing..."
end

-- Set personality
function AIRobot:setPersonality(personality)
    self.personality = personality
    robotState.personality = personality
    
    -- Update personality indicator
    local personalityColors = {
        helpful = {0.2, 0.8, 0.2, 0.8},
        friendly = {0.8, 0.2, 0.8, 0.8},
        professional = {0.2, 0.2, 0.8, 0.8}
    }
    
    if self.personalityIndicator and personalityColors[personality] then
        self.personalityIndicator:setFillColor(unpack(personalityColors[personality]))
    end
end

-- Get state
function AIRobot:getState()
    return robotState
end

-- Cleanup
function AIRobot:cleanup()
    if self.animationTimer then
        timer.cancel(self.animationTimer)
    end
end

return AIRobot