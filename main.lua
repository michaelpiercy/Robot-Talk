-- Caleb's AI Assistant - Main Application
-- Expert-level Solar2D implementation with comprehensive error handling

-- Get display dimensions
local _w = display.actualContentWidth
local _h = display.actualContentHeight

-- Validate display dimensions
if not _w or not _h then
    print("Error: Invalid display dimensions")
    return
end

-- Application state
local app = {
    aiRobot = nil,
    uiManager = nil,
    personalityButtons = {},
    currentPersonalityIndex = 1
}

-- Personality options
local personalities = {
    "helpful",
    "creative", 
    "analytical",
    "friendly"
}

-- Safe module loading function
local function safeRequire(modulePath)
    local success, result = pcall(require, modulePath)
    if success then
        return result
    else
        print("Warning: Failed to load module:", modulePath, "-", result)
        return nil
    end
end

-- Safe function call wrapper
local function safeCall(func, ...)
    if func and type(func) == "function" then
        local success, result = pcall(func, ...)
        if not success then
            print("Warning: Function call failed:", result)
        end
        return success, result
    end
    return false, "Function not available"
end

-- Create personality selector
local function createPersonalitySelector()
    if not _w or not _h then
        print("Error: Invalid dimensions for personality selector")
        return
    end
    
    local buttonWidth = 80
    local buttonHeight = 30
    local spacing = 10
    local startX = (_w - (#personalities * (buttonWidth + spacing) - spacing)) / 2
    
    for i, personality in ipairs(personalities) do
        local button = display.newRoundedRect(
            startX + (i-1) * (buttonWidth + spacing),
            80,
            buttonWidth,
            buttonHeight,
            15
        )
        
        if button then
            button:setFillColor(0.8, 0.8, 0.8, 0.8)
            button:setStrokeColor(0.6, 0.6, 0.6, 1)
            button.strokeWidth = 1
            
            local buttonText = display.newText({
                text = personality:sub(1,1):upper() .. personality:sub(2),
                x = button.x,
                y = button.y,
                font = native.systemFont,
                fontSize = 12
            })
            
            if buttonText then
                buttonText:setFillColor(0.3, 0.3, 0.3, 1)
            end
            
            -- Store reference
            app.personalityButtons[i] = button
            
            -- Add tap handler
            button:addEventListener("tap", function()
                -- Reset all buttons
                for j, btn in ipairs(app.personalityButtons) do
                    if btn then
                        btn:setFillColor(0.8, 0.8, 0.8, 0.8)
                    end
                end
                
                -- Highlight selected button
                button:setFillColor(0.2, 0.6, 1.0, 0.9)
                
                -- Update personality
                app.currentPersonalityIndex = i
                if app.aiRobot and app.aiRobot.setPersonality then
                    safeCall(app.aiRobot.setPersonality, app.aiRobot, personality)
                end
            end)
        end
    end
end

-- Initialize the application
local function initApp()
    print("Initializing Caleb's AI Assistant...")
    
    -- Create background
    local background = display.newRect(_w/2, _h/2, _w, _h)
    if background then
        background:setFillColor(0.95, 0.97, 1.0, 1)
    end
    
    -- Create title
    local title = display.newText({
        text = "Caleb's AI Assistant",
        x = _w/2,
        y = 20,
        font = native.systemFontBold,
        fontSize = 18
    })
    if title then
        title:setFillColor(0.2, 0.2, 0.2, 1)
    end
    
    -- Initialize AI Robot
    local AIRobot = safeRequire("Definitions.ai_robot")
    if AIRobot then
        app.aiRobot = AIRobot:new()
        if app.aiRobot and app.aiRobot.createSprite then
            local robotSprite = safeCall(app.aiRobot.createSprite, app.aiRobot)
            if not robotSprite then
                print("Warning: Failed to create robot sprite")
            end
        end
    else
        print("Warning: AI Robot module not available")
    end
    
    -- Initialize UI Manager
    local UIManager = safeRequire("Framework.ui_manager")
    if UIManager then
        app.uiManager = UIManager:new()
        if app.uiManager and app.uiManager.init then
            local initSuccess = safeCall(app.uiManager.init, app.uiManager)
            if not initSuccess then
                print("Warning: UI Manager initialization failed")
            end
        end
        
        -- Make AI robot available to UI manager
        if app.uiManager then
            app.uiManager.aiRobot = app.aiRobot
        end
    else
        print("Warning: UI Manager module not available")
    end
    
    -- Create personality selector
    createPersonalitySelector()
    
    -- Set initial personality
    if app.aiRobot and app.aiRobot.setPersonality then
        safeCall(app.aiRobot.setPersonality, app.aiRobot, "helpful")
    end
    
    if app.personalityButtons[1] then
        app.personalityButtons[1]:setFillColor(0.2, 0.6, 1.0, 0.9)
    end
    
    -- Add welcome message
    timer.performWithDelay(500, function()
        if app.uiManager and app.uiManager.addChatBubble then
            safeCall(app.uiManager.addChatBubble, app.uiManager, "Hello! I'm Caleb's AI assistant. How can I help you today?", false)
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
    if systemInfo then
        systemInfo:setFillColor(0.5, 0.5, 0.5, 1)
    end
    
    print("AI Assistant initialized successfully!")
end

-- Handle keyboard events
local function onKeyEvent(event)
    if event.phase == "down" then
        if event.keyName == "enter" or event.keyName == "return" then
            if app.uiManager and app.uiManager.handleSend then
                safeCall(app.uiManager.handleSend, app.uiManager)
            end
            return true
        end
    end
    return false
end

-- Handle system events
local function onSystemEvent(event)
    if event.type == "applicationExit" then
        -- Cleanup AI robot
        if app.aiRobot and app.aiRobot.cleanup then
            safeCall(app.aiRobot.cleanup, app.aiRobot)
        end
    end
end

-- Initialize the application
initApp()

-- Add event listeners
Runtime:addEventListener("key", onKeyEvent)
Runtime:addEventListener("system", onSystemEvent)
