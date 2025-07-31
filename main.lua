---@meta
---@diagnostic disable: undefined-global

-- Caleb's AI Assistant - Main Application
-- Expert-level Solar2D implementation with comprehensive error handling

-- ============================================================================
-- DEBUG CONFIGURATION
-- ============================================================================

---@type boolean Debug mode flag for console output
local DEBUG_MODE = true

---Debug print function
---@param message string The debug message to print
local function debugPrint(message)
    if DEBUG_MODE then
        print("[DEBUG] " .. message)
    end
end

-- ============================================================================
-- DEPENDENCY MANAGEMENT & SCOPE CONTROL
-- ============================================================================

-- Get display dimensions (must be first)
---@type number Display width in pixels
local _w = display.actualContentWidth
---@type number Display height in pixels
local _h = display.actualContentHeight

-- Validate display dimensions (critical validation)
if not _w or not _h then
    print("Error: Invalid display dimensions")
    return
end

-- ============================================================================
-- APPLICATION STATE MANAGEMENT
-- ============================================================================

---@class AppState
---@field modules table<string, any> Core modules loaded in dependency order
---@field personalityButtons table<number, DisplayObject> Array of personality selector buttons
---@field currentPersonalityIndex number Current selected personality index
---@field isInitialized boolean Whether the application has been initialized
---@field isShuttingDown boolean Whether the application is shutting down

---@type AppState Central application state (single source of truth)
local app = {
    -- Core modules (loaded in dependency order)
    modules = {
        knowledgeBase = nil,
        llmCore = nil,
        aiRobot = nil,
        uiManager = nil
    },
    
    -- UI state
    personalityButtons = {},
    currentPersonalityIndex = 1,
    
    -- System state
    isInitialized = false,
    isShuttingDown = false
}

-- Personality options (immutable configuration)
---@type string[] Personality options (immutable configuration)
local personalities = {
    "helpful",
    "creative", 
    "analytical",
    "friendly"
}

-- ============================================================================
-- SAFETY & ERROR HANDLING FUNCTIONS
-- ============================================================================

-- Safe module loading with dependency tracking
---@param modulePath string The path to the module to load
---@param dependencyName? string The name to store the module under in app.modules
---@return any|nil The loaded module or nil if failed
local function safeRequire(modulePath, dependencyName)
    if not modulePath then
        print("Error: No module path provided")
        return nil
    end
    
    local success, result = pcall(require, modulePath)
    if success then
        if dependencyName then
            app.modules[dependencyName] = result
            debugPrint("✓ Loaded module: " .. dependencyName)
        end
        return result
    else
        print("✗ Failed to load module:", modulePath, "-", result)
        return nil
    end
end

-- Safe function call wrapper with scope validation
---@param func function|nil The function to call
---@param context table|nil The context object (self) for the function
---@param ... any Additional arguments to pass to the function
---@return boolean success Whether the function call succeeded
---@return any result The result of the function call or error message
local function safeCall(func, context, ...)
    if not func then
        print("Warning: Function not provided")
        return false, "Function not available"
    end
    
    if type(func) ~= "function" then
        print("Warning: Invalid function type")
        return false, "Invalid function type"
    end
    
    if context and type(context) ~= "table" then
        print("Warning: Invalid context object")
        return false, "Invalid context"
    end
    
    local success, result = pcall(func, context, ...)
    if not success then
        print("Warning: Function call failed:", result)
    end
    return success, result
end

-- ============================================================================
-- MODULE INITIALIZATION (DEPENDENCY ORDER)
-- ============================================================================

-- Initialize modules in dependency order
---@return boolean success Whether all critical modules were loaded successfully
local function initializeModules()
    debugPrint("Initializing modules in dependency order...")
    
    -- 1. Load Knowledge Base first (no dependencies)
    local KnowledgeBase = safeRequire("Definitions.knowledge_base", "knowledgeBase")
    if not KnowledgeBase then
        print("Critical Error: Knowledge Base required for system operation")
        return false
    end
    
    -- 2. Load LLM Core (depends on Knowledge Base)
    local LLMCore = safeRequire("Definitions.llm_core", "llmCore")
    if not LLMCore then
        print("Critical Error: LLM Core required for AI functionality")
        return false
    end
    
    -- 3. Load AI Robot (depends on LLM Core)
    local AIRobot = safeRequire("Definitions.ai_robot", "aiRobot")
    if not AIRobot then
        print("Warning: AI Robot not available, continuing without visual feedback")
    end
    
    -- 4. Load UI Manager (depends on all other modules)
    local UIManager = safeRequire("Framework.ui_manager", "uiManager")
    if not UIManager then
        print("Critical Error: UI Manager required for user interaction")
        return false
    end
    
    debugPrint("✓ All modules loaded successfully")
    return true
end

-- ============================================================================
-- UI COMPONENT CREATION (SCOPE ISOLATED)
-- ============================================================================

-- Create personality selector with proper scope
---@return boolean success Whether the personality selector was created successfully
local function createPersonalitySelector()
    if not _w or not _h then
        print("Error: Invalid dimensions for personality selector")
        return false
    end
    
    if not personalities or #personalities == 0 then
        print("Error: No personality options defined")
        return false
    end
    
    local buttonWidth = 80
    local buttonHeight = 30
    local spacing = 10
    local startX = (_w - (#personalities * (buttonWidth + spacing) - spacing)) / 2
    
    for i, personality in ipairs(personalities) do
        ---@type DisplayObject
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
            
            ---@type TextObject
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
            
            -- Store reference in app state
            app.personalityButtons[i] = button
            
            -- Add tap handler with proper scope
            button:addEventListener("tap", function()
                -- Validate app state before proceeding
                if app.isShuttingDown then
                    print("Warning: App shutting down, ignoring tap")
                    return
                end
                
                -- Reset all buttons
                for j, btn in ipairs(app.personalityButtons) do
                    if btn then
                        btn:setFillColor(0.8, 0.8, 0.8, 0.8)
                    end
                end
                
                -- Highlight selected button
                button:setFillColor(0.2, 0.6, 1.0, 0.9)
                
                -- Update personality with proper validation
                app.currentPersonalityIndex = i
                if app.modules.aiRobot and app.modules.aiRobot.setPersonality then
                    safeCall(app.modules.aiRobot.setPersonality, app.modules.aiRobot, personality)
                end
            end)
        end
    end
    
    return true
end

-- ============================================================================
-- TEST FUNCTIONS
-- ============================================================================

-- Test chat bubble creation
---@return boolean success Whether the test was successful
local function testChatBubbles()
    if not app.modules.uiManager then
        debugPrint("✗ UI Manager not available for testing")
        return false
    end
    
    debugPrint("Testing chat bubble creation...")
    
    -- Test user bubble
    local userSuccess = safeCall(app.modules.uiManager.addChatBubble, app.modules.uiManager, "This is a test user message", true)
    if userSuccess then
        debugPrint("✓ User chat bubble test successful")
    else
        debugPrint("✗ User chat bubble test failed")
    end
    
    -- Test AI bubble
    local aiSuccess = safeCall(app.modules.uiManager.addChatBubble, app.modules.uiManager, "This is a test AI response", false)
    if aiSuccess then
        debugPrint("✓ AI chat bubble test successful")
    else
        debugPrint("✗ AI chat bubble test failed")
    end
    
    return userSuccess and aiSuccess
end

-- ============================================================================
-- APPLICATION INITIALIZATION (EXECUTION ORDER)
-- ============================================================================

-- Initialize the application with proper scope and order
---@return boolean success Whether the application was initialized successfully
local function initApp()
    debugPrint("Initializing Caleb's AI Assistant...")
    
    -- Step 1: Load all modules in dependency order
    if not initializeModules() then
        print("Critical Error: Module initialization failed")
        return false
    end
    
    -- Step 2: Create UI components
    ---@type DisplayObject
    local background = display.newRect(_w/2, _h/2, _w, _h)
    if background then
        background:setFillColor(0.95, 0.97, 1.0, 1)
    end
    
    ---@type TextObject
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
    
    -- Step 3: Initialize AI Robot with proper scope
    if app.modules.aiRobot then
        ---@type AIRobot
        local robotInstance = app.modules.aiRobot:new()
        if robotInstance and robotInstance.createSprite then
            ---@type DisplayObject|nil
            local robotSprite = safeCall(robotInstance.createSprite, robotInstance)
            if not robotSprite then
                print("Warning: Failed to create robot sprite")
            end
        end
        app.modules.aiRobot = robotInstance
    end
    
    -- Step 4: Initialize UI Manager with proper scope and dependency injection
    if app.modules.uiManager then
        ---@type UIManager
        local uiInstance = app.modules.uiManager:new()
        if uiInstance and uiInstance.init then
            local initSuccess = safeCall(uiInstance.init, uiInstance)
            if not initSuccess then
                print("Warning: UI Manager initialization failed")
            end
        end
        
        -- CRITICAL: Establish proper object relationships with dependency injection
        if uiInstance then
            debugPrint("Injecting dependencies into UI Manager...")
            
            -- Inject LLM Core instance
            if app.modules.llmCore then
                local llmInstance = app.modules.llmCore:new()
                uiInstance.state.llmCore = llmInstance
                debugPrint("✓ LLM Core injected into UI Manager")
            else
                debugPrint("✗ LLM Core not available for injection")
            end
            
            -- Inject Knowledge Base instance
            if app.modules.knowledgeBase then
                local kbInstance = app.modules.knowledgeBase:new()
                uiInstance.state.knowledgeBase = kbInstance
                debugPrint("✓ Knowledge Base injected into UI Manager")
            else
                debugPrint("✗ Knowledge Base not available for injection")
            end
            
            -- Inject AI Robot instance
            uiInstance.state.aiRobot = app.modules.aiRobot
            debugPrint("✓ AI Robot injected into UI Manager")
            
            -- Enable debug mode in UI Manager
            uiInstance.state.debugMode = DEBUG_MODE
            debugPrint("✓ Debug mode enabled in UI Manager")
        end
        app.modules.uiManager = uiInstance
    end
    
    -- Step 5: Create personality selector
    if not createPersonalitySelector() then
        print("Warning: Personality selector creation failed")
    end
    
    -- Step 6: Set initial personality
    if app.modules.aiRobot and app.modules.aiRobot.setPersonality then
        safeCall(app.modules.aiRobot.setPersonality, app.modules.aiRobot, "helpful")
    end
    
    if app.personalityButtons[1] then
        app.personalityButtons[1]:setFillColor(0.2, 0.6, 1.0, 0.9)
    end
    
    -- Step 7: Test chat bubbles
    timer.performWithDelay(1000, function()
        testChatBubbles()
    end)
    
    -- Step 8: Add welcome message with proper timing
    timer.performWithDelay(2000, function()
        if app.isShuttingDown then return end
        
        if app.modules.uiManager and app.modules.uiManager.addChatBubble then
            safeCall(app.modules.uiManager.addChatBubble, app.modules.uiManager, "Hello! I'm Caleb's AI assistant. How can I help you today?", false)
        end
    end)
    
    -- Step 9: Add system info
    ---@type TextObject
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
    
    -- Step 10: Mark initialization complete
    app.isInitialized = true
    debugPrint("✓ AI Assistant initialized successfully!")
    return true
end

-- ============================================================================
-- EVENT HANDLERS (SCOPE AWARE)
-- ============================================================================

-- Handle keyboard events with proper scope validation
---@param event table The keyboard event object
---@return boolean handled Whether the event was handled
local function onKeyEvent(event)
    if app.isShuttingDown then
        return false
    end
    
    if event.phase == "down" then
        if event.keyName == "enter" or event.keyName == "return" then
            if app.modules.uiManager and app.modules.uiManager.handleSend then
                safeCall(app.modules.uiManager.handleSend, app.modules.uiManager)
            end
            return true
        end
    end
    return false
end

-- Handle system events with proper cleanup
---@param event table The system event object
local function onSystemEvent(event)
    if event.type == "applicationExit" then
        app.isShuttingDown = true
        
        -- Cleanup AI robot
        if app.modules.aiRobot and app.modules.aiRobot.cleanup then
            safeCall(app.modules.aiRobot.cleanup, app.modules.aiRobot)
        end
        
        -- Cleanup UI manager
        if app.modules.uiManager and app.modules.uiManager.cleanup then
            safeCall(app.modules.uiManager.cleanup, app.modules.uiManager)
        end
        
        print("✓ Application shutdown complete")
    end
end

-- ============================================================================
-- APPLICATION STARTUP (FINAL EXECUTION ORDER)
-- ============================================================================

-- Initialize the application
if not initApp() then
    print("Critical Error: Application initialization failed")
    return
end

-- Add event listeners (must be last)
Runtime:addEventListener("key", onKeyEvent)
Runtime:addEventListener("system", onSystemEvent)
