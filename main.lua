-- Caleb's AI Assistant
-- Main application file for Solar2D

-- Initialize display dimensions
local _w = display.actualContentWidth
local _h = display.actualContentHeight

-- Global variables for app state
local app = {}
app.aiRobot = nil
app.uiManager = nil
app.personalityButtons = {}
app.currentPersonalityIndex = 1

-- Create personality selector buttons
local function createPersonalitySelector()
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
            if app.aiRobot then
                app.aiRobot:setPersonality(personality)
            end
            
            -- Update button colors
            for i, btn in ipairs(app.personalityButtons) do
                if i == app.currentPersonalityIndex then
                    btn:setFillColor(0.2, 0.6, 1.0, 0.9)
                else
                    btn:setFillColor(0.7, 0.7, 0.7, 0.8)
                end
            end
            
            -- Find new personality index
            for i, pers in ipairs(personalities) do
                if pers == personality then
                    app.currentPersonalityIndex = i
                    break
                end
            end
        end)
        
        return button
    end
    
    -- Create personality buttons
    for i, personality in ipairs(personalities) do
        local x = 100 + (i-1) * 90
        local button = createPersonalityButton(personality, x, 80, personality)
        table.insert(app.personalityButtons, button)
    end
end

-- Initialize the application
local function initApp()
    print("Initializing Caleb's AI Assistant...")
    
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
    
    -- Initialize AI Robot
    local AIRobot = require("Definitions.ai_robot")
    app.aiRobot = AIRobot:new()
    local robotSprite = app.aiRobot:createSprite()
    
    -- Initialize UI Manager
    local UIManager = require("Framework.ui_manager")
    app.uiManager = UIManager:new()
    app.uiManager:init()
    
    -- Make AI robot available to UI manager
    app.uiManager.aiRobot = app.aiRobot
    
    -- Create personality selector
    createPersonalitySelector()
    
    -- Set initial personality
    app.aiRobot:setPersonality("helpful")
    if app.personalityButtons[1] then
        app.personalityButtons[1]:setFillColor(0.2, 0.6, 1.0, 0.9)
    end
    
    -- Add welcome message
    timer.performWithDelay(500, function()
        if app.uiManager and app.uiManager.addChatBubble then
            app.uiManager:addChatBubble("Hello! I'm Caleb's AI assistant. How can I help you today?", false)
        end
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
    
    print("AI Assistant initialized successfully!")
end

-- Keyboard event handler
local function onKeyEvent(event)
    if event.phase == "down" and event.keyName == "enter" then
        if app.uiManager and app.uiManager.handleSend then
            app.uiManager:handleSend()
        end
        return true
    end
    return false
end

-- System event handler
local function onSystemEvent(event)
    if event.type == "applicationExit" then
        if app.aiRobot and app.aiRobot.cleanup then
            app.aiRobot:cleanup()
        end
    end
end

-- Initialize the app
initApp()

-- Add event listeners
Runtime:addEventListener("key", onKeyEvent)
Runtime:addEventListener("system", onSystemEvent)
