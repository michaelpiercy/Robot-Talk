print("-- Caleb's AI Assistant - Enhanced LLM System")

-- Initialize display dimensions
_w = display.actualContentWidth
_h = display.actualContentHeight

-- Load modules
local LLMCore = require("Definitions.llm_core")
local AIRobot = require("Definitions.ai_robot")
local UIManager = require("Framework.ui_manager")

-- Initialize the AI system
local aiRobot = AIRobot:new()
local uiManager = UIManager

-- Make AI robot available to UI manager
uiManager.aiRobot = aiRobot

-- Create background
local background = display.newRect(_w/2, _h/2, _w, _h)
background:setFillColor(0.95, 0.97, 1.0, 1)

-- Create title
local title = display.newText({
    text = "Caleb's AI Assistant",
    x = _w/2,
    y = 20,
    font = native.systemFontBold,
    fontSize = 18
})
title:setFillColor(0.2, 0.2, 0.2, 1)

-- Initialize UI
uiManager:init()

-- Create and setup AI Robot
local robotSprite = aiRobot:createSprite()

-- Add personality selector
local personalityLabel = display.newText({
    text = "Personality:",
    x = 20,
    y = 80,
    font = native.systemFont,
    fontSize = 12,
    align = "left"
})
personalityLabel:setFillColor(0.3, 0.3, 0.3, 1)
personalityLabel.anchorX = 0

local personalities = {"helpful", "friendly", "professional"}
local currentPersonalityIndex = 1

local function createPersonalityButton(text, x, y, personality)
    local button = display.newRoundedRect(x, y, 80, 25, 12)
    button:setFillColor(0.7, 0.7, 0.7, 0.8)
    button:setStrokeColor(0.5, 0.5, 0.5, 1)
    button.strokeWidth = 1
    
    local buttonText = display.newText({
        text = text,
        x = x,
        y = y,
        font = native.systemFont,
        fontSize = 10
    })
    buttonText:setFillColor(0.2, 0.2, 0.2, 1)
    
    button:addEventListener("tap", function()
        aiRobot:setPersonality(personality)
        -- Update button colors
        for i, btn in ipairs(personalityButtons) do
            if i == currentPersonalityIndex then
                btn:setFillColor(0.2, 0.6, 1.0, 0.9)
            else
                btn:setFillColor(0.7, 0.7, 0.7, 0.8)
            end
        end
        for i, pers in ipairs(personalities) do
            if pers == personality then
                currentPersonalityIndex = i
                break
            end
        end
    end)
    
    return button
end

local personalityButtons = {}
for i, personality in ipairs(personalities) do
    local x = 100 + (i-1) * 90
    local button = createPersonalityButton(personality, x, 80, personality)
    table.insert(personalityButtons, button)
end

-- Set initial personality
aiRobot:setPersonality("helpful")
personalityButtons[1]:setFillColor(0.2, 0.6, 1.0, 0.9)

-- Add welcome message
timer.performWithDelay(500, function()
    uiManager:addChatBubble("Hello! I'm Caleb's AI assistant. How can I help you today?", false)
end)

-- Add system info
local systemInfo = display.newText({
    text = "AI System v2.0 - Enhanced LLM with Memory & Context",
    x = _w/2,
    y = _h - 20,
    font = native.systemFont,
    fontSize = 10
})
systemInfo:setFillColor(0.5, 0.5, 0.5, 1)

-- Add keyboard handling
local function onKeyEvent(event)
    if event.phase == "down" and event.keyName == "enter" then
        uiManager:handleSend()
        return true
    end
    return false
end

Runtime:addEventListener("key", onKeyEvent)

-- Add system cleanup
local function onSystemEvent(event)
    if event.type == "applicationExit" then
        aiRobot:cleanup()
    end
end

Runtime:addEventListener("system", onSystemEvent)

print("AI Assistant initialized successfully!")
