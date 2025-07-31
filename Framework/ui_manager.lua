---@meta
---@diagnostic disable: undefined-global

-- UI Manager for Caleb's AI Assistant
-- Expert-level Solar2D implementation with comprehensive error handling

-- ============================================================================
-- MODULE DEFINITION & INSTANCE MANAGEMENT
-- ============================================================================

---@class UIManager
---@field state UIState The instance-specific state
local UIManager = {}

-- ============================================================================
-- INSTANCE STATE MANAGEMENT
-- ============================================================================

---@class UIState
---@field chatContainer DisplayObject|nil The chat container display object
---@field inputField DisplayObject|nil The input field display object
---@field sendButton DisplayObject|nil The send button display object
---@field statusLabel TextObject|nil The status label display object
---@field memoryLabel TextObject|nil The memory label display object
---@field clearButton DisplayObject|nil The clear button display object
---@field activeDialog boolean Whether a dialog is currently active
---@field dialogElements DisplayObject[] Array of dialog display objects
---@field aiRobot AIRobot|nil Reference to the AI robot instance
---@field llmCore LLMCore|nil Reference to the LLM core instance
---@field knowledgeBase KnowledgeBase|nil Reference to the knowledge base instance
---@field isInitialized boolean Whether the UI manager is initialized
---@field demoCounter number Counter for demo messages
---@field displayWidth number The display width in pixels
---@field displayHeight number The display height in pixels
---@field debugMode boolean Whether debug mode is enabled
---@field conversationLog string[] Array of conversation messages for debugging

---Instance-specific state (not module globals)
---@return UIState The initialized UI state
local function createInstanceState()
    return {
        -- UI Elements (instance-specific)
        chatContainer = nil,
        inputField = nil,
        sendButton = nil,
        statusLabel = nil,
        memoryLabel = nil,
        clearButton = nil,
        
        -- Dialog state management (instance-specific)
        activeDialog = nil,
        dialogElements = {},
        
        -- Module dependencies (injected from main)
        aiRobot = nil,
        llmCore = nil,
        knowledgeBase = nil,
        
        -- Instance state
        isInitialized = false,
        demoCounter = 0,
        
        -- Display dimensions (instance-specific)
        displayWidth = display.actualContentWidth,
        displayHeight = display.actualContentHeight,
        
        -- Debug mode (enabled by default)
        debugMode = true,
        conversationLog = {}
    }
end

-- ============================================================================
-- SAFETY & UTILITY FUNCTIONS (INSTANCE-AGNOSTIC)
-- ============================================================================

---Safe element removal function
---@param element DisplayObject|nil The display object to remove
local function safeRemove(element)
    if element and element.removeSelf then
        local success, err = pcall(function()
            element:removeSelf()
        end)
        if not success then
            print("Warning: Failed to remove element:", err)
        end
    end
end

---Input validation function
---@param text string|nil The text to validate
---@return boolean valid Whether the input is valid
---@return string|string sanitized The sanitized text or error message
local function validateInput(text)
    if not text then return false, "No input provided" end
    if type(text) ~= "string" then return false, "Invalid input type" end
    if string.len(text) == 0 then return false, "Empty input" end
    if string.len(text) > 1000 then return false, "Input too long" end
    
    -- Sanitize input - remove dangerous characters
    local sanitized = string.gsub(text, "[<>\"']", "")
    if sanitized ~= text then
        print("Warning: Input sanitized")
    end
    
    return true, sanitized
end

---Debug print function
---@param message string The debug message to print
local function debugPrint(message)
    print("[UI DEBUG] " .. message)
end

-- ============================================================================
-- INSTANCE METHODS (PROPER SCOPE)
-- ============================================================================

---Constructor with proper instance isolation
---@return UIManager The new UI manager instance
function UIManager:new()
    local instance = {}
    setmetatable(instance, { __index = UIManager })
    
    -- Initialize instance state
    instance.state = createInstanceState()
    
    return instance
end

---Initialize the UI with proper scope
---@return boolean success Whether the UI manager was initialized successfully
function UIManager:init()
    if self.state.isInitialized then
        print("Warning: UI Manager already initialized")
        return true
    end
    
    debugPrint("Initializing UI Manager...")
    
    -- Validate display dimensions
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid display dimensions")
        return false
    end
    
    -- Create UI components in dependency order
    if not self:createChatContainer() then
        print("Error: Failed to create chat container")
        return false
    end
    
    if not self:createInputArea() then
        print("Error: Failed to create input area")
        return false
    end
    
    if not self:createStatusBar() then
        print("Error: Failed to create status bar")
        return false
    end
    
    if not self:createMemoryDisplay() then
        print("Error: Failed to create memory display")
        return false
    end
    
    self.state.isInitialized = true
    debugPrint("✓ UI Manager initialized successfully!")
    return true
end

---Create chat container with instance scope
---@return boolean success Whether the chat container was created successfully
function UIManager:createChatContainer()
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid dimensions for chat container")
        return false
    end
    
    debugPrint("Creating chat container for dimensions: " .. self.state.displayWidth .. " x " .. self.state.displayHeight)
    
    -- Create the main chat container as a display group
    self.state.chatContainer = display.newGroup()
    if not self.state.chatContainer then
        print("Error: Failed to create chat container")
        return false
    end
    
    -- Position the chat container properly for Android portrait
    -- Leave space for status bar at top and input area at bottom
    local topMargin = 80  -- Space for title and status
    local bottomMargin = 120  -- Space for input area
    local sideMargin = 20  -- Side margins
    
    self.state.chatContainer.x = self.state.displayWidth / 2
    self.state.chatContainer.y = topMargin + (self.state.displayHeight - topMargin - bottomMargin) / 2
    self.state.chatContainer.width = self.state.displayWidth - (sideMargin * 2)
    self.state.chatContainer.height = self.state.displayHeight - topMargin - bottomMargin
    
    debugPrint("Chat container positioned at: " .. self.state.chatContainer.x .. ", " .. self.state.chatContainer.y)
    debugPrint("Chat container size: " .. self.state.chatContainer.width .. " x " .. self.state.chatContainer.height)
    
    -- Create a visible background for the chat area
    ---@type DisplayObject
    local chatBackground = display.newRoundedRect(0, 0, self.state.chatContainer.width, self.state.chatContainer.height, 10)
    if chatBackground then
        chatBackground:setFillColor(0.95, 0.95, 0.95, 0.8)  -- More visible background
        chatBackground:setStrokeColor(0.7, 0.7, 0.7, 1)      -- Visible border
        chatBackground.strokeWidth = 2
        self.state.chatContainer:insert(chatBackground)
        debugPrint("Chat background created")
    end
    
    -- Create messages group as a separate display group
    self.state.chatContainer.messagesGroup = display.newGroup()
    if self.state.chatContainer.messagesGroup then
        -- Position messages group relative to chat container
        self.state.chatContainer.messagesGroup.x = 0
        self.state.chatContainer.messagesGroup.y = 0
        self.state.chatContainer.messagesGroup.width = self.state.chatContainer.width - 20
        self.state.chatContainer.messagesGroup.height = self.state.chatContainer.height - 20
        
        -- Insert messages group into chat container
        self.state.chatContainer:insert(self.state.chatContainer.messagesGroup)
        debugPrint("Messages group created and inserted")
        
        -- Add a visual debug indicator to show the messages group boundaries
        if self.state.debugMode then
            ---@type DisplayObject
            local debugBorder = display.newRect(0, 0, self.state.chatContainer.messagesGroup.width, self.state.chatContainer.messagesGroup.height)
            if debugBorder then
                debugBorder:setFillColor(0, 0, 0, 0)  -- Transparent fill
                debugBorder:setStrokeColor(1, 0, 0, 0.5)  -- Red border for debugging
                debugBorder.strokeWidth = 1
                self.state.chatContainer.messagesGroup:insert(debugBorder)
                debugPrint("Debug border added to messages group")
            end
        end
    end
    
    -- Initialize message tracking
    self.state.chatContainer.currentY = 10
    self.state.chatContainer.maxY = self.state.chatContainer.height - 20
    
    debugPrint("Chat container setup complete - Messages group children: " .. (self.state.chatContainer.messagesGroup and self.state.chatContainer.messagesGroup.numChildren or 0))
    return true
end

---Create input area with instance scope
---@return boolean success Whether the input area was created successfully
function UIManager:createInputArea()
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid dimensions for input area")
        return false
    end
    
    debugPrint("Creating input area for dimensions: " .. self.state.displayWidth .. " x " .. self.state.displayHeight)
    
    -- Input background - positioned at bottom for Android portrait
    ---@type DisplayObject
    local inputBg = display.newRoundedRect(self.state.displayWidth/2, self.state.displayHeight - 80, self.state.displayWidth - 40, 50, 25)
    if inputBg then
        inputBg:setFillColor(0.9, 0.9, 0.9, 0.8)
        inputBg:setStrokeColor(0.7, 0.7, 0.7, 1)
        inputBg.strokeWidth = 2
    end
    
    -- Create proper text input field for Solar2D simulator
    local success, result = pcall(function()
        self.state.inputField = native.newTextField(self.state.displayWidth/2, self.state.displayHeight - 80, self.state.displayWidth - 80, 40)
        if self.state.inputField then
            self.state.inputField.placeholder = "Type your message here..."
            self.state.inputField.font = native.newFont(native.systemFont, 16)
            self.state.inputField:addEventListener("userInput", function(event)
                if event.phase == "submitted" then
                    self:handleSend()
                end
            end)
        end
        return self.state.inputField
    end)
    
    if not success or not self.state.inputField then
        print("Warning: Native text field not available, using fallback")
        -- Create a clickable text input simulation
        self.state.inputField = display.newText({
            text = "Click to type message",
            x = self.state.displayWidth/2,
            y = self.state.displayHeight - 80,
            font = native.systemFont,
            fontSize = 16
        })
        if self.state.inputField then
            self.state.inputField:setFillColor(0.5, 0.5, 0.5, 1)
            self.state.inputField.text = ""
            self.state.inputField.isSimulated = true
            
            -- Add tap handler for simulated input
            self.state.inputField:addEventListener("tap", function()
                self:showTextInputDialog()
            end)
        end
    end
    
    -- Send button - properly sized for Android portrait
    self.state.sendButton = display.newRoundedRect(self.state.displayWidth - 50, self.state.displayHeight - 80, 40, 40, 20)
    if self.state.sendButton then
        self.state.sendButton:setFillColor(0.2, 0.6, 1.0, 0.9)
        self.state.sendButton:setStrokeColor(0.1, 0.4, 0.8, 1)
        self.state.sendButton.strokeWidth = 2
        
        ---@type TextObject
        local sendText = display.newText({
            text = "Send",
            x = self.state.sendButton.x,
            y = self.state.sendButton.y,
            font = native.systemFont,
            fontSize = 12
        })
        if sendText then
            sendText:setFillColor(1, 1, 1, 1)
        end
        
        self.state.sendButton:addEventListener("tap", function()
            self:handleSend()
        end)
    end
    
    return true
end

---Create status bar with instance scope
---@return boolean success Whether the status bar was created successfully
function UIManager:createStatusBar()
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid dimensions for status bar")
        return false
    end
    
    self.state.statusLabel = display.newText({
        text = "AI Assistant Ready",
        x = 20,
        y = 50,
        font = native.systemFont,
        fontSize = 14,
        align = "left"
    })
    if self.state.statusLabel then
        self.state.statusLabel:setFillColor(0.3, 0.3, 0.3, 1)
        self.state.statusLabel.anchorX = 0
    end
    
    return true
end

---Create memory display with instance scope
---@return boolean success Whether the memory display was created successfully
function UIManager:createMemoryDisplay()
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid dimensions for memory display")
        return false
    end
    
    self.state.memoryLabel = display.newText({
        text = "Memory: 0 conversations",
        x = self.state.displayWidth - 20,
        y = 50,
        font = native.systemFont,
        fontSize = 12,
        align = "right"
    })
    if self.state.memoryLabel then
        self.state.memoryLabel:setFillColor(0.5, 0.5, 0.5, 1)
        self.state.memoryLabel.anchorX = 1
    end
    
    -- Clear memory button - properly sized for Android portrait
    self.state.clearButton = display.newRoundedRect(self.state.displayWidth - 80, 80, 60, 30, 15)
    if self.state.clearButton then
        self.state.clearButton:setFillColor(0.8, 0.3, 0.3, 0.8)
        
        ---@type TextObject
        local clearText = display.newText({
            text = "Clear",
            x = self.state.clearButton.x,
            y = self.state.clearButton.y,
            font = native.systemFont,
            fontSize = 12
        })
        if clearText then
            clearText:setFillColor(1, 1, 1, 1)
        end
        
        self.state.clearButton:addEventListener("tap", function()
            self:handleClearMemory()
        end)
    end
    
    return true
end

-- ============================================================================
-- DIALOG MANAGEMENT (INSTANCE-SCOPED)
-- ============================================================================

---Safe cleanup dialog elements
function UIManager:cleanupDialog()
    if self.state.activeDialog then
        for _, element in ipairs(self.state.dialogElements) do
            safeRemove(element)
        end
        self.state.dialogElements = {}
        self.state.activeDialog = nil
    end
end

---Show text input dialog for simulator
function UIManager:showTextInputDialog()
    -- Prevent multiple dialogs
    if self.state.activeDialog then
        print("Warning: Dialog already active")
        return
    end
    
    self.state.activeDialog = true
    self.state.dialogElements = {}
    
    -- Create dialog background
    ---@type DisplayObject
    local dialogBg = display.newRoundedRect(self.state.displayWidth/2, self.state.displayHeight/2, 300, 150, 20)
    if dialogBg then
        dialogBg:setFillColor(1, 1, 1, 0.95)
        dialogBg:setStrokeColor(0.7, 0.7, 0.7, 1)
        dialogBg.strokeWidth = 2
        table.insert(self.state.dialogElements, dialogBg)
    end
    
    -- Create title
    ---@type TextObject
    local title = display.newText({
        text = "Enter your message:",
        x = self.state.displayWidth/2,
        y = self.state.displayHeight/2 - 40,
        font = native.systemFont,
        fontSize = 16
    })
    if title then
        title:setFillColor(0.2, 0.2, 0.2, 1)
        table.insert(self.state.dialogElements, title)
    end
    
    -- Create input field for dialog
    ---@type DisplayObject|nil
    local dialogInput = nil
    local success, result = pcall(function()
        dialogInput = native.newTextField(self.state.displayWidth/2, self.state.displayHeight/2, 250, 30)
        if dialogInput then
            dialogInput.placeholder = "Type here..."
            dialogInput.font = native.newFont(native.systemFont, 14)
            dialogInput:setTextColor(0, 0, 0, 1)
            table.insert(self.state.dialogElements, dialogInput)
        end
        return dialogInput
    end)
    
    if not success or not dialogInput then
        print("Warning: Failed to create dialog input field")
        self:cleanupDialog()
        return
    end
    
    -- Create send button
    ---@type DisplayObject
    local sendBtn = display.newRoundedRect(self.state.displayWidth/2 + 80, self.state.displayHeight/2 + 30, 60, 30, 15)
    if sendBtn then
        sendBtn:setFillColor(0.2, 0.6, 1.0, 0.9)
        table.insert(self.state.dialogElements, sendBtn)
    end
    
    ---@type TextObject
    local sendText = display.newText({
        text = "Send",
        x = sendBtn and sendBtn.x or self.state.displayWidth/2 + 80,
        y = sendBtn and sendBtn.y or self.state.displayHeight/2 + 30,
        font = native.systemFont,
        fontSize = 12
    })
    if sendText then
        sendText:setFillColor(1, 1, 1, 1)
        table.insert(self.state.dialogElements, sendText)
    end
    
    -- Create cancel button
    ---@type DisplayObject
    local cancelBtn = display.newRoundedRect(self.state.displayWidth/2 - 80, self.state.displayHeight/2 + 30, 60, 30, 15)
    if cancelBtn then
        cancelBtn:setFillColor(0.7, 0.7, 0.7, 0.9)
        table.insert(self.state.dialogElements, cancelBtn)
    end
    
    ---@type TextObject
    local cancelText = display.newText({
        text = "Cancel",
        x = cancelBtn and cancelBtn.x or self.state.displayWidth/2 - 80,
        y = cancelBtn and cancelBtn.y or self.state.displayHeight/2 + 30,
        font = native.systemFont,
        fontSize = 12
    })
    if cancelText then
        cancelText:setFillColor(1, 1, 1, 1)
        table.insert(self.state.dialogElements, cancelText)
    end
    
    -- Handle send button
    if sendBtn then
        sendBtn:addEventListener("tap", function()
            if dialogInput then
                local userText = dialogInput.text
                local isValid, sanitizedText = validateInput(userText)
                
                if isValid then
                    self:processUserInput(sanitizedText)
                else
                    print("Input validation failed:", sanitizedText)
                end
            end
            self:cleanupDialog()
        end)
    end
    
    -- Handle cancel button
    if cancelBtn then
        cancelBtn:addEventListener("tap", function()
            self:cleanupDialog()
        end)
    end
end

-- ============================================================================
-- CORE FUNCTIONALITY (INSTANCE-SCOPED)
-- ============================================================================

---Process user input with validation
---@param text string The user input text to process
function UIManager:processUserInput(text)
    local isValid, sanitizedText = validateInput(text)
    if not isValid then
        print("Input validation failed:", sanitizedText)
        return
    end
    
    debugPrint("Processing user input: " .. sanitizedText)
    
    -- Add user message to chat
    self:addChatBubble(sanitizedText, true)
    
    -- Log conversation for debugging
    table.insert(self.state.conversationLog, "User: " .. sanitizedText)
    
    -- Update status
    self:updateStatus("AI Assistant - Processing...")
    
    -- Process with LLM (using injected dependencies)
    if self.state.llmCore then
        debugPrint("LLM Core available, processing with AI...")
        
        -- Process input with AI robot for visual feedback
        if self.state.aiRobot and self.state.aiRobot.processInput then
            local robotSuccess, robotErr = pcall(function()
                self.state.aiRobot:processInput(sanitizedText)
            end)
            if not robotSuccess then
                debugPrint("Warning: Robot processing failed: " .. tostring(robotErr))
            else
                debugPrint("✓ Robot processed input successfully")
            end
        end
        
        -- Generate response
        local responseSuccess, response = pcall(function()
            return self.state.llmCore:processInput(sanitizedText)
        end)
        
        if responseSuccess and response then
            debugPrint("AI Response: " .. response)
            
            -- Add AI response to chat
            self:addChatBubble(response, false)
            
            -- Log conversation for debugging
            table.insert(self.state.conversationLog, "AI: " .. response)
            
            -- Update memory stats
            local statsSuccess, stats = pcall(function()
                return self.state.llmCore:getMemoryStats()
            end)
            
            if statsSuccess and stats then
                self:updateMemoryStats(stats)
                self:updateStatus("AI Assistant - " .. (stats.conversationCount or 0) .. " messages")
            else
                self:updateStatus("AI Assistant - Response Generated")
            end
        else
            debugPrint("Warning: LLM response generation failed")
            self:addChatBubble("I'm having trouble processing that right now.", false)
            self:updateStatus("AI Assistant - Processing Error")
        end
    else
        debugPrint("LLM Core not available, using fallback response")
        -- Fallback response
        local fallbackResponses = {
            "That's an interesting question!",
            "I'd be happy to help with that.",
            "Let me think about that...",
            "That's a great point!",
            "I understand what you're asking."
        }
        local response = fallbackResponses[math.random(1, #fallbackResponses)]
        self:addChatBubble(response, false)
        self:updateStatus("AI Assistant - Demo Mode")
        
        -- Log conversation for debugging
        table.insert(self.state.conversationLog, "AI: " .. response)
    end
    
    -- Print conversation log if debug mode is enabled
    if self.state.debugMode then
        debugPrint("=== CONVERSATION LOG ===")
        for i, message in ipairs(self.state.conversationLog) do
            debugPrint(i .. ". " .. message)
        end
        debugPrint("========================")
    end
end

---Add chat bubble with instance scope
---@param text string The text to display in the chat bubble
---@param isUser boolean Whether this is a user message (true) or AI message (false)
---@return DisplayObject|nil The created chat bubble group or nil if failed
function UIManager:addChatBubble(text, isUser)
    if not text then
        print("Error: No text provided for chat bubble")
        return
    end
    
    if not self.state.chatContainer or not self.state.chatContainer.messagesGroup then
        print("Error: Chat container not initialized")
        return
    end
    
    debugPrint("Adding chat bubble: " .. (isUser and "User" or "AI") .. " - " .. text)
    debugPrint("Messages group children before: " .. self.state.chatContainer.messagesGroup.numChildren)
    debugPrint("Current Y position: " .. (self.state.chatContainer.currentY or "nil"))
    
    ---@class BubbleStyle
    ---@field backgroundColor number[] Background color RGBA values
    ---@field textColor number[] Text color RGBA values
    ---@field cornerRadius number Corner radius for rounded rectangle
    ---@field maxWidth number Maximum width of the bubble
    
    ---@type table<string, BubbleStyle>
    local bubbleStyle = {
        userBubble = {
            backgroundColor = {0.2, 0.6, 1.0, 1.0},  -- More opaque blue
            textColor = {1, 1, 1, 1},
            cornerRadius = 15,
            maxWidth = 200  -- Appropriate width for Android portrait
        },
        aiBubble = {
            backgroundColor = {0.9, 0.9, 0.9, 1.0},  -- More opaque gray
            textColor = {0.2, 0.2, 0.2, 1},
            cornerRadius = 15,
            maxWidth = 200  -- Appropriate width for Android portrait
        }
    }
    
    local style = isUser and bubbleStyle.userBubble or bubbleStyle.aiBubble
    
    -- Create bubble background with more visible styling
    ---@type DisplayObject
    local bubble = display.newRoundedRect(0, 0, style.maxWidth, 60, style.cornerRadius)
    if not bubble then
        print("Error: Failed to create bubble background")
        return
    end
    
    bubble:setFillColor(unpack(style.backgroundColor))
    bubble:setStrokeColor(0.5, 0.5, 0.5, 1)  -- More visible border
    bubble.strokeWidth = 2
    
    -- Create text with better visibility
    ---@type TextObject
    local textObj = display.newText({
        text = text,
        x = 0,
        y = 0,
        width = style.maxWidth - 20,
        font = native.systemFont,
        fontSize = 14,
        align = "left"
    })
    if not textObj then
        print("Error: Failed to create bubble text")
        safeRemove(bubble)
        return
    end
    
    textObj:setFillColor(unpack(style.textColor))
    
    -- Group bubble and text
    ---@type DisplayObject
    local bubbleGroup = display.newGroup()
    if bubbleGroup then
        bubbleGroup:insert(bubble)
        bubbleGroup:insert(textObj)
        
        -- Calculate bubble position within the messages group
        local bubbleX, bubbleY
        
        if isUser then
            -- User bubbles on the right side
            bubbleX = self.state.chatContainer.messagesGroup.width - bubble.width/2 - 20
        else
            -- AI bubbles on the left side
            bubbleX = bubble.width/2 + 20
        end
        
        -- Position vertically with proper spacing
        bubbleY = (self.state.chatContainer.currentY or 10) + 30
        
        -- Ensure bubble stays within bounds
        if bubbleX < bubble.width/2 then
            bubbleX = bubble.width/2 + 10
        elseif bubbleX > self.state.chatContainer.messagesGroup.width - bubble.width/2 then
            bubbleX = self.state.chatContainer.messagesGroup.width - bubble.width/2 - 10
        end
        
        -- Set bubble position
        bubbleGroup.x = bubbleX
        bubbleGroup.y = bubbleY
        
        debugPrint("Bubble positioned at: " .. bubbleX .. ", " .. bubbleY)
        debugPrint("Messages group size: " .. self.state.chatContainer.messagesGroup.width .. " x " .. self.state.chatContainer.messagesGroup.height)
        debugPrint("Bubble size: " .. bubble.width .. " x " .. bubble.height)
        
        -- Add to messages group
        self.state.chatContainer.messagesGroup:insert(bubbleGroup)
        
        debugPrint("Messages group children after: " .. self.state.chatContainer.messagesGroup.numChildren)
        
        -- Update current Y position for next bubble
        self.state.chatContainer.currentY = bubbleY + 70
        
        -- Simple auto-scroll if we're running out of space
        if self.state.chatContainer.currentY > (self.state.chatContainer.maxY or 400) then
            debugPrint("Auto-scrolling messages...")
            for i = 1, self.state.chatContainer.messagesGroup.numChildren do
                local child = self.state.chatContainer.messagesGroup[i]
                if child and child.y then
                    child.y = child.y - 80
                end
            end
            self.state.chatContainer.currentY = self.state.chatContainer.currentY - 80
        end
        
        return bubbleGroup
    end
end

---Update status with instance scope
---@param text string The status text to display
function UIManager:updateStatus(text)
    if self.state.statusLabel and text then
        self.state.statusLabel.text = text
        debugPrint("Status updated: " .. text)
    end
end

---Update memory stats with instance scope
---@param stats table The memory statistics table
function UIManager:updateMemoryStats(stats)
    if self.state.memoryLabel and stats then
        self.state.memoryLabel.text = "Memory: " .. (stats.conversationCount or 0) .. " conversations"
        debugPrint("Memory stats updated: " .. (stats.conversationCount or 0) .. " conversations")
    end
end

---Handle send button with instance scope
function UIManager:handleSend()
    debugPrint("Send button pressed")
    
    -- Check if we have a real text field
    if self.state.inputField and self.state.inputField.text then
        local text = self.state.inputField.text
        local isValid, sanitizedText = validateInput(text)
        
        if isValid then
            self:processUserInput(sanitizedText)
            -- Clear the input field
            self.state.inputField.text = ""
            if self.state.inputField.setText then
                self.state.inputField:setText("")
            end
        else
            print("Input validation failed:", sanitizedText)
        end
    else
        debugPrint("No real input field, using demo mode")
        -- Fallback to demo mode if no real input
        local demoMessages = {
            "Hello! How are you today?",
            "What is artificial intelligence?",
            "Tell me about programming",
            "How does the internet work?",
            "What is the weather like?"
        }
        
        local demoIndex = (self.state.demoCounter or 0) % #demoMessages + 1
        local text = demoMessages[demoIndex]
        self.state.demoCounter = (self.state.demoCounter or 0) + 1
        
        if text and text ~= "" then
            self:processUserInput(text)
        end
    end
end

---Handle clear memory with instance scope
function UIManager:handleClearMemory()
    debugPrint("Clearing memory and conversation")
    
    -- Clear chat display properly
    if self.state.chatContainer and self.state.chatContainer.messagesGroup then
        debugPrint("Removing old messages group")
        self.state.chatContainer.messagesGroup:removeSelf()
        
        -- Create new messages group with proper positioning
        self.state.chatContainer.messagesGroup = display.newGroup()
        if self.state.chatContainer.messagesGroup then
            -- Position messages group at the top of the chat container
            self.state.chatContainer.messagesGroup.x = 0
            self.state.chatContainer.messagesGroup.y = 0
            self.state.chatContainer.messagesGroup.width = self.state.chatContainer.width - 20
            self.state.chatContainer.messagesGroup.height = self.state.chatContainer.height - 20
            
            -- Insert messages group into chat container
            self.state.chatContainer:insert(self.state.chatContainer.messagesGroup)
            
            -- Reset message tracking
            self.state.chatContainer.currentY = 10
            self.state.chatContainer.maxY = self.state.chatContainer.height - 20
            
            debugPrint("New messages group created and positioned")
            debugPrint("Messages group children: " .. self.state.chatContainer.messagesGroup.numChildren)
        end
    end
    
    -- Reset demo counter
    self.state.demoCounter = 0
    
    -- Clear conversation log
    self.state.conversationLog = {}
    
    -- Update displays
    self:updateStatus("Memory cleared - AI Assistant Ready")
    self:updateMemoryStats({conversationCount = 0})
end

---Cleanup function with instance scope
function UIManager:cleanup()
    print("Cleaning up UI Manager...")
    
    -- Cleanup dialog
    self:cleanupDialog()
    
    -- Remove display objects
    safeRemove(self.state.chatContainer)
    safeRemove(self.state.inputField)
    safeRemove(self.state.sendButton)
    safeRemove(self.state.statusLabel)
    safeRemove(self.state.memoryLabel)
    safeRemove(self.state.clearButton)
    
    -- Reset state
    self.state = createInstanceState()
    self.state.isInitialized = false
    
    print("✓ UI Manager cleanup completed")
end

return UIManager