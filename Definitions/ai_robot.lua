---@meta
---@diagnostic disable: undefined-global

-- AI Robot Module for Caleb's AI Assistant
-- Expert-level Solar2D implementation with comprehensive error handling

---@class AIRobot
---@field sprite DisplayObject|nil The robot sprite display object
---@field personalityIndicator TextObject|nil The personality indicator text
---@field energyBar DisplayObject|nil The energy bar display object
---@field moodIndicator TextObject|nil The mood indicator text
---@field currentPersonality string The current personality setting
---@field currentMood string The current mood state
---@field energyLevel number The current energy level (0-100)
---@field isAnimating boolean Whether an animation is currently playing

local AIRobot = {}

-- ============================================================================
-- ROBOT STATE MANAGEMENT
-- ============================================================================

---@class RobotState
---@field sprite DisplayObject|nil The robot sprite display object
---@field personalityIndicator TextObject|nil The personality indicator text
---@field energyBar DisplayObject|nil The energy bar display object
---@field moodIndicator TextObject|nil The mood indicator text
---@field currentPersonality string The current personality setting
---@field currentMood string The current mood state
---@field energyLevel number The current energy level (0-100)
---@field isAnimating boolean Whether an animation is currently playing

---@type RobotState Robot state
local robotState = {
    sprite = nil,
    personalityIndicator = nil,
    energyBar = nil,
    moodIndicator = nil,
    currentPersonality = "helpful",
    currentMood = "neutral",
    energyLevel = 100,
    isAnimating = false
}

-- ============================================================================
-- ANIMATION CONFIGURATION
-- ============================================================================

---@class AnimationConfig
---@field duration number Animation duration in milliseconds
---@field alpha? number[] Alpha values for animation
---@field scale? number[] Scale values for animation
---@field rotation? number[] Rotation values for animation

---@type table<string, AnimationConfig> Animation states
local animations = {
    idle = {
        duration = 2000,
        alpha = {1.0, 0.8, 1.0},
        scale = {1.0, 1.05, 1.0}
    },
    thinking = {
        duration = 1500,
        rotation = {0, 5, -5, 0},
        scale = {1.0, 1.1, 1.0}
    },
    excited = {
        duration = 800,
        scale = {1.0, 1.2, 1.0},
        alpha = {1.0, 0.9, 1.0}
    },
    sad = {
        duration = 1200,
        scale = {1.0, 0.9, 1.0},
        alpha = {1.0, 0.7, 1.0}
    }
}

-- ============================================================================
-- PERSONALITY RESPONSES
-- ============================================================================

---@class PersonalityResponses
---@field greeting string Greeting response
---@field thinking string Thinking response
---@field excited string Excited response
---@field sad string Sad response

---@type table<string, PersonalityResponses> Personality responses
local personalityResponses = {
    helpful = {
        greeting = "Hello! How can I assist you today?",
        thinking = "Let me think about that...",
        excited = "That's a great question!",
        sad = "I'm here to help if you need anything."
    },
    creative = {
        greeting = "Hi there! Ready to explore some creative ideas?",
        thinking = "Let me brainstorm some possibilities...",
        excited = "What an imaginative question!",
        sad = "Creativity can help us through difficult times."
    },
    analytical = {
        greeting = "Greetings. I'm ready to analyze and solve problems.",
        thinking = "Analyzing the data...",
        excited = "Excellent analytical question!",
        sad = "Let's approach this systematically."
    },
    friendly = {
        greeting = "Hey! Great to see you! How are you doing?",
        thinking = "Let me think about that for you...",
        excited = "That's awesome! I love this question!",
        sad = "Don't worry, we'll figure this out together!"
    }
}

-- ============================================================================
-- SAFETY & UTILITY FUNCTIONS
-- ============================================================================

---Safe element removal function
---@param element DisplayObject|nil The display object to remove
local function safeRemove(element)
    if element and element.removeSelf then
        local success, err = pcall(function()
            element:removeSelf()
        end)
        if not success then
            print("Warning: Failed to remove robot element:", err)
        end
    end
end

---Safe transition function
---@param target DisplayObject|nil The target display object
---@param params table The transition parameters
---@return boolean success Whether the transition was successful
local function safeTransition(target, params)
    if target and transition and transition.to then
        local success, err = pcall(function()
            transition.to(target, params)
        end)
        if not success then
            print("Warning: Transition failed:", err)
        end
        return success
    end
    return false
end

-- ============================================================================
-- CORE ROBOT FUNCTIONALITY
-- ============================================================================

---Create robot sprite
---@return DisplayObject|nil The created robot sprite or nil if failed
function AIRobot:createSprite()
    if not display or not display.newImageRect then
        print("Error: Display system not available")
        return nil
    end
    
    -- Get display dimensions
    local _w = display.actualContentWidth
    local _h = display.actualContentHeight
    
    if not _w or not _h then
        print("Error: Invalid display dimensions for robot sprite")
        return nil
    end
    
    -- Create robot body (simple rectangle for now)
    ---@type DisplayObject
    local robotBody = display.newRoundedRect(_w/2, _h/2 - 150, 80, 100, 20)
    if not robotBody then
        print("Error: Failed to create robot body")
        return nil
    end
    
    robotBody:setFillColor(0.3, 0.3, 0.3, 1)
    robotBody:setStrokeColor(0.1, 0.1, 0.1, 1)
    robotBody.strokeWidth = 3
    
    -- Create robot head
    ---@type DisplayObject
    local robotHead = display.newCircle(_w/2, _h/2 - 200, 30)
    if robotHead then
        robotHead:setFillColor(0.4, 0.4, 0.4, 1)
        robotHead:setStrokeColor(0.2, 0.2, 0.2, 1)
        robotHead.strokeWidth = 2
    end
    
    -- Create eyes
    ---@type DisplayObject
    local leftEye = display.newCircle(_w/2 - 10, _h/2 - 205, 5)
    if leftEye then
        leftEye:setFillColor(0, 1, 0, 1) -- Green eyes
    end
    
    ---@type DisplayObject
    local rightEye = display.newCircle(_w/2 + 10, _h/2 - 205, 5)
    if rightEye then
        rightEye:setFillColor(0, 1, 0, 1) -- Green eyes
    end
    
    -- Create personality indicator
    ---@type TextObject
    local personalityIndicator = display.newText({
        text = "Helpful",
        x = _w/2,
        y = _h/2 - 50,
        font = native.systemFont,
        fontSize = 12
    })
    if personalityIndicator then
        personalityIndicator:setFillColor(0.2, 0.6, 1.0, 1)
    end
    
    -- Create energy bar background
    ---@type DisplayObject
    local energyBarBg = display.newRect(_w/2, _h/2 - 20, 100, 10)
    if energyBarBg then
        energyBarBg:setFillColor(0.8, 0.8, 0.8, 1)
        energyBarBg:setStrokeColor(0.5, 0.5, 0.5, 1)
        energyBarBg.strokeWidth = 1
    end
    
    -- Create energy bar
    ---@type DisplayObject
    local energyBar = display.newRect(_w/2 - 45, _h/2 - 20, 90, 8)
    if energyBar then
        energyBar:setFillColor(0.2, 0.8, 0.2, 1)
        energyBar.anchorX = 0
    end
    
    -- Create mood indicator
    ---@type TextObject
    local moodIndicator = display.newText({
        text = "😊",
        x = _w/2,
        y = _h/2 + 10,
        font = native.systemFont,
        fontSize = 20
    })
    if moodIndicator then
        moodIndicator:setFillColor(1, 1, 1, 1)
    end
    
    -- Store references
    robotState.sprite = robotBody
    robotState.personalityIndicator = personalityIndicator
    robotState.energyBar = energyBar
    robotState.moodIndicator = moodIndicator
    
    -- Start idle animation
    self:startIdleAnimation()
    
    return robotBody
end

---Play animation
---@param animationType string The type of animation to play
---@return boolean success Whether the animation was started successfully
function AIRobot:playAnimation(animationType)
    if not animationType or not animations[animationType] then
        print("Warning: Invalid animation type:", animationType)
        return false
    end
    
    if robotState.isAnimating then
        print("Warning: Animation already in progress")
        return false
    end
    
    local animation = animations[animationType]
    if not animation then
        print("Warning: Animation not found:", animationType)
        return false
    end
    
    robotState.isAnimating = true
    
    -- Stop current animation
    if robotState.sprite then
        transition.cancel(robotState.sprite)
    end
    
    -- Apply animation based on type
    if animationType == "idle" then
        if robotState.sprite then
            safeTransition(robotState.sprite, {
                time = animation.duration,
                alpha = animation.alpha[1],
                xScale = animation.scale[1],
                yScale = animation.scale[1],
                onComplete = function()
                    robotState.isAnimating = false
                    -- Continue idle animation
                    timer.performWithDelay(100, function()
                        self:playAnimation("idle")
                    end)
                end
            })
        end
    elseif animationType == "thinking" then
        if robotState.sprite then
            safeTransition(robotState.sprite, {
                time = animation.duration,
                rotation = animation.rotation[1],
                xScale = animation.scale[1],
                yScale = animation.scale[1],
                onComplete = function()
                    robotState.isAnimating = false
                end
            })
        end
    elseif animationType == "excited" then
        if robotState.sprite then
            safeTransition(robotState.sprite, {
                time = animation.duration,
                xScale = animation.scale[1],
                yScale = animation.scale[1],
                alpha = animation.alpha[1],
                onComplete = function()
                    robotState.isAnimating = false
                end
            })
        end
    elseif animationType == "sad" then
        if robotState.sprite then
            safeTransition(robotState.sprite, {
                time = animation.duration,
                xScale = animation.scale[1],
                yScale = animation.scale[1],
                alpha = animation.alpha[1],
                onComplete = function()
                    robotState.isAnimating = false
                end
            })
        end
    end
    
    return true
end

---Start idle animation
function AIRobot:startIdleAnimation()
    if not robotState.isAnimating then
        self:playAnimation("idle")
    end
end

---Update mood
---@param mood string The mood to set
---@return boolean success Whether the mood was updated successfully
function AIRobot:updateMood(mood)
    if not mood then
        print("Warning: No mood specified")
        return false
    end
    
    robotState.currentMood = mood
    
    ---@type table<string, string> Mood emoji mapping
    local moodEmojis = {
        happy = "😊",
        excited = "🤖",
        thinking = "🤔",
        sad = "😔",
        neutral = "😐"
    }
    
    if robotState.moodIndicator and moodEmojis[mood] then
        robotState.moodIndicator.text = moodEmojis[mood]
        return true
    end
    
    return false
end

---Update energy bar
---@param energy number The energy level (0-100)
---@return boolean success Whether the energy bar was updated successfully
function AIRobot:updateEnergyBar(energy)
    if not energy or type(energy) ~= "number" then
        print("Warning: Invalid energy value")
        return false
    end
    
    energy = math.max(0, math.min(100, energy))
    robotState.energyLevel = energy
    
    if robotState.energyBar then
        local width = (energy / 100) * 90
        robotState.energyBar.width = width
        
        -- Change color based on energy level
        if energy > 70 then
            robotState.energyBar:setFillColor(0.2, 0.8, 0.2, 1) -- Green
        elseif energy > 30 then
            robotState.energyBar:setFillColor(1.0, 0.8, 0.2, 1) -- Yellow
        else
            robotState.energyBar:setFillColor(0.8, 0.2, 0.2, 1) -- Red
        end
        
        return true
    end
    
    return false
end

---Process input and determine sentiment
---@param input string The input text to analyze
---@return string|false sentiment The detected sentiment or false if failed
function AIRobot:processInput(input)
    if not input or type(input) ~= "string" then
        print("Warning: Invalid input for robot processing")
        return false
    end
    
    -- Simple sentiment analysis
    ---@type string[] Positive words for sentiment analysis
    local positiveWords = {"good", "great", "awesome", "excellent", "amazing", "love", "like", "happy", "excited"}
    ---@type string[] Negative words for sentiment analysis
    local negativeWords = {"bad", "terrible", "awful", "hate", "dislike", "sad", "angry", "frustrated"}
    ---@type string[] Question words for sentiment analysis
    local questionWords = {"what", "how", "why", "when", "where", "who", "which", "?"}
    
    local inputLower = string.lower(input)
    local sentiment = "neutral"
    local isQuestion = false
    
    -- Check for questions
    for _, word in ipairs(questionWords) do
        if string.find(inputLower, word) then
            isQuestion = true
            break
        end
    end
    
    -- Check sentiment
    local positiveCount = 0
    local negativeCount = 0
    
    for _, word in ipairs(positiveWords) do
        if string.find(inputLower, word) then
            positiveCount = positiveCount + 1
        end
    end
    
    for _, word in ipairs(negativeWords) do
        if string.find(inputLower, word) then
            negativeCount = negativeCount + 1
        end
    end
    
    if positiveCount > negativeCount then
        sentiment = "happy"
    elseif negativeCount > positiveCount then
        sentiment = "sad"
    elseif isQuestion then
        sentiment = "thinking"
    end
    
    -- Update robot state
    self:updateMood(sentiment)
    
    -- Play appropriate animation
    if sentiment == "happy" then
        self:playAnimation("excited")
    elseif sentiment == "sad" then
        self:playAnimation("sad")
    elseif sentiment == "thinking" then
        self:playAnimation("thinking")
    end
    
    -- Update energy (simple simulation)
    local energyChange = 0
    if sentiment == "happy" then
        energyChange = 5
    elseif sentiment == "sad" then
        energyChange = -3
    elseif sentiment == "thinking" then
        energyChange = -1
    end
    
    self:updateEnergyBar(robotState.energyLevel + energyChange)
    
    return sentiment
end

---Get personality response
---@param responseType string The type of response to get
---@return string The personality response
function AIRobot:getPersonalityResponse(responseType)
    if not responseType or not robotState.currentPersonality then
        return "I'm here to help!"
    end
    
    local personality = personalityResponses[robotState.currentPersonality]
    if not personality then
        return "I'm here to help!"
    end
    
    return personality[responseType] or "I'm here to help!"
end

---Set personality
---@param personality string The personality to set
---@return boolean success Whether the personality was set successfully
function AIRobot:setPersonality(personality)
    if not personality or type(personality) ~= "string" then
        print("Warning: Invalid personality specified")
        return false
    end
    
    robotState.currentPersonality = personality
    
    if robotState.personalityIndicator then
        robotState.personalityIndicator.text = personality:sub(1,1):upper() .. personality:sub(2)
    end
    
    return true
end

---Cleanup function
function AIRobot:cleanup()
    print("Cleaning up AI Robot...")
    
    -- Stop animations
    if robotState.sprite then
        transition.cancel(robotState.sprite)
    end
    
    -- Remove display objects
    safeRemove(robotState.sprite)
    safeRemove(robotState.personalityIndicator)
    safeRemove(robotState.energyBar)
    safeRemove(robotState.moodIndicator)
    
    -- Reset state
    robotState = {
        sprite = nil,
        personalityIndicator = nil,
        energyBar = nil,
        moodIndicator = nil,
        currentPersonality = "helpful",
        currentMood = "neutral",
        energyLevel = 100,
        isAnimating = false
    }
    
    print("AI Robot cleanup completed")
end

---Constructor
---@return AIRobot The new AI robot instance
function AIRobot:new()
    local robot = {}
    setmetatable(robot, { __index = AIRobot })
    return robot
end

return AIRobot