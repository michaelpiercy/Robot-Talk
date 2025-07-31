-- UI Manager for Caleb's AI Assistant
-- Expert-level Solar2D implementation with comprehensive error handling

-- ============================================================================
-- MODULE DEFINITION & INSTANCE MANAGEMENT
-- ============================================================================

local UIManager = {}

-- ============================================================================
-- INSTANCE STATE MANAGEMENT
-- ============================================================================

-- Instance-specific state (not module globals)
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
        displayHeight = display.actualContentHeight
    }
end

-- ============================================================================
-- SAFETY & UTILITY FUNCTIONS (INSTANCE-AGNOSTIC)
-- ============================================================================

-- Safe element removal function
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

-- Input validation function
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

-- ============================================================================
-- INSTANCE METHODS (PROPER SCOPE)
-- ============================================================================

-- Constructor with proper instance isolation
function UIManager:new()
    local instance = {}
    setmetatable(instance, { __index = UIManager })
    
    -- Initialize instance state
    instance.state = createInstanceState()
    
    return instance
end

-- Initialize the UI with proper scope
function UIManager:init()
    if self.state.isInitialized then
        print("Warning: UI Manager already initialized")
        return true
    end
    
    print("Initializing UI Manager...")
    
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
    print("✓ UI Manager initialized successfully!")
    return true
end

-- Create chat container with instance scope
function UIManager:createChatContainer()
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid dimensions for chat container")
        return false
    end
    
    self.state.chatContainer = display.newGroup()
    if not self.state.chatContainer then
        print("Error: Failed to create chat container")
        return false
    end
    
    self.state.chatContainer.x = self.state.displayWidth/2
    self.state.chatContainer.y = self.state.displayHeight/2 - 100
    self.state.chatContainer.width = self.state.displayWidth - 40
    self.state.chatContainer.height = self.state.displayHeight - 200
    
    -- Create chat background
    local chatBackground = display.newRoundedRect(self.state.chatContainer.x, self.state.chatContainer.y, self.state.chatContainer.width, self.state.chatContainer.height, 10)
    if chatBackground then
        chatBackground:setFillColor(0.95, 0.95, 0.95, 0.3)
        chatBackground:setStrokeColor(0.8, 0.8, 0.8, 0.5)
        chatBackground.strokeWidth = 1
        self.state.chatContainer:insert(chatBackground)
    end
    
    -- Create messages group
    self.state.chatContainer.messagesGroup = display.newGroup()
    if self.state.chatContainer.messagesGroup then
        self.state.chatContainer.messagesGroup.x = self.state.chatContainer.x
        self.state.chatContainer.messagesGroup.y = self.state.chatContainer.y
        self.state.chatContainer.messagesGroup.width = self.state.chatContainer.width - 20
        self.state.chatContainer.messagesGroup.height = self.state.chatContainer.height - 20
        self.state.chatContainer:insert(self.state.chatContainer.messagesGroup)
    end
    
    -- Initialize message tracking
    self.state.chatContainer.currentY = 10
    self.state.chatContainer.maxY = self.state.chatContainer.height - 20
    
    return true
end

-- Create input area with instance scope
function UIManager:createInputArea()
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid dimensions for input area")
        return false
    end
    
    -- Input background
    local inputBg = display.newRoundedRect(self.state.displayWidth/2, self.state.displayHeight - 80, self.state.displayWidth - 120, 50, 25)
    if inputBg then
        inputBg:setFillColor(0.9, 0.9, 0.9, 0.8)
        inputBg:setStrokeColor(0.7, 0.7, 0.7, 1)
        inputBg.strokeWidth = 2
    end
    
    -- Create proper text input field for Solar2D simulator
    local success, result = pcall(function()
        self.state.inputField = native.newTextField(self.state.displayWidth/2, self.state.displayHeight - 80, self.state.displayWidth - 160, 40)
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
    
    -- Send button
    self.state.sendButton = display.newRoundedRect(self.state.displayWidth - 60, self.state.displayHeight - 80, 50, 40, 20)
    if self.state.sendButton then
        self.state.sendButton:setFillColor(0.2, 0.6, 1.0, 0.9)
        self.state.sendButton:setStrokeColor(0.1, 0.4, 0.8, 1)
        self.state.sendButton.strokeWidth = 2
        
        local sendText = display.newText({
            text = "Send",
            x = self.state.sendButton.x,
            y = self.state.sendButton.y,
            font = native.systemFont,
            fontSize = 14
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

-- Create status bar with instance scope
function UIManager:createStatusBar()
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid dimensions for status bar")
        return false
    end
    
    self.state.statusLabel = display.newText({
        text = "AI Assistant Ready",
        x = 20,
        y = 40,
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

-- Create memory display with instance scope
function UIManager:createMemoryDisplay()
    if not self.state.displayWidth or not self.state.displayHeight then
        print("Error: Invalid dimensions for memory display")
        return false
    end
    
    self.state.memoryLabel = display.newText({
        text = "Memory: 0 conversations",
        x = self.state.displayWidth - 20,
        y = 40,
        font = native.systemFont,
        fontSize = 12,
        align = "right"
    })
    if self.state.memoryLabel then
        self.state.memoryLabel:setFillColor(0.5, 0.5, 0.5, 1)
        self.state.memoryLabel.anchorX = 1
    end
    
    -- Clear memory button
    self.state.clearButton = display.newRoundedRect(self.state.displayWidth - 100, 60, 80, 25, 12)
    if self.state.clearButton then
        self.state.clearButton:setFillColor(0.8, 0.3, 0.3, 0.8)
        
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

-- Safe cleanup dialog elements
function UIManager:cleanupDialog()
    if self.state.activeDialog then
        for _, element in ipairs(self.state.dialogElements) do
            safeRemove(element)
        end
        self.state.dialogElements = {}
        self.state.activeDialog = nil
    end
end

-- Show text input dialog for simulator
function UIManager:showTextInputDialog()
    -- Prevent multiple dialogs
    if self.state.activeDialog then
        print("Warning: Dialog already active")
        return
    end
    
    self.state.activeDialog = true
    self.state.dialogElements = {}
    
    -- Create dialog background
    local dialogBg = display.newRoundedRect(self.state.displayWidth/2, self.state.displayHeight/2, 300, 150, 20)
    if dialogBg then
        dialogBg:setFillColor(1, 1, 1, 0.95)
        dialogBg:setStrokeColor(0.7, 0.7, 0.7, 1)
        dialogBg.strokeWidth = 2
        table.insert(self.state.dialogElements, dialogBg)
    end
    
    -- Create title
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
    local sendBtn = display.newRoundedRect(self.state.displayWidth/2 + 80, self.state.displayHeight/2 + 30, 60, 30, 15)
    if sendBtn then
        sendBtn:setFillColor(0.2, 0.6, 1.0, 0.9)
        table.insert(self.state.dialogElements, sendBtn)
    end
    
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
    local cancelBtn = display.newRoundedRect(self.state.displayWidth/2 - 80, self.state.displayHeight/2 + 30, 60, 30, 15)
    if cancelBtn then
        cancelBtn:setFillColor(0.7, 0.7, 0.7, 0.9)
        table.insert(self.state.dialogElements, cancelBtn)
    end
    
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

-- Process user input with validation
function UIManager:processUserInput(text)
    local isValid, sanitizedText = validateInput(text)
    if not isValid then
        print("Input validation failed:", sanitizedText)
        return
    end
    
    -- Add user message to chat
    self:addChatBubble(sanitizedText, true)
    
    -- Update status
    self:updateStatus("AI Assistant - Processing...")
    
    -- Process with LLM (using injected dependencies)
    if self.state.llmCore then
        -- Process input with AI robot for visual feedback
        if self.state.aiRobot and self.state.aiRobot.processInput then
            local robotSuccess, robotErr = pcall(function()
                self.state.aiRobot:processInput(sanitizedText)
            end)
            if not robotSuccess then
                print("Warning: Robot processing failed:", robotErr)
            end
        end
        
        -- Generate response
        local responseSuccess, response = pcall(function()
            return self.state.llmCore:processInput(sanitizedText)
        end)
        
        if responseSuccess and response then
            -- Add AI response to chat
            self:addChatBubble(response, false)
            
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
            self:addChatBubble("I'm having trouble processing that right now.", false)
            self:updateStatus("AI Assistant - Processing Error")
        end
    else
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
    end
end

-- Add chat bubble with instance scope
function UIManager:addChatBubble(text, isUser)
    if not text then
        print("Error: No text provided for chat bubble")
        return
    end
    
    if not self.state.chatContainer or not self.state.chatContainer.messagesGroup then
        print("Error: Chat container not initialized")
        return
    end
    
    local bubbleStyle = {
        userBubble = {
            backgroundColor = {0.2, 0.6, 1.0, 0.9},
            textColor = {1, 1, 1, 1},
            cornerRadius = 15,
            maxWidth = 250
        },
        aiBubble = {
            backgroundColor = {0.9, 0.9, 0.9, 0.9},
            textColor = {0.2, 0.2, 0.2, 1},
            cornerRadius = 15,
            maxWidth = 250
        }
    }
    
    local style = isUser and bubbleStyle.userBubble or bubbleStyle.aiBubble
    
    -- Create bubble background
    local bubble = display.newRoundedRect(0, 0, style.maxWidth, 60, style.cornerRadius)
    if not bubble then
        print("Error: Failed to create bubble background")
        return
    end
    
    bubble:setFillColor(unpack(style.backgroundColor))
    bubble:setStrokeColor(0.7, 0.7, 0.7, 0.5)
    bubble.strokeWidth = 1
    
    -- Create text
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
    local bubbleGroup = display.newGroup()
    if bubbleGroup then
        bubbleGroup:insert(bubble)
        bubbleGroup:insert(textObj)
        
        -- Position bubble
        if isUser then
            bubbleGroup.x = self.state.chatContainer.width - bubble.width/2 - 20
        else
            bubbleGroup.x = bubble.width/2 + 20
        end
        
        -- Position vertically
        bubbleGroup.y = self.state.chatContainer.currentY + 30
        
        -- Add to messages group
        self.state.chatContainer.messagesGroup:insert(bubbleGroup)
        
        -- Update current Y position
        self.state.chatContainer.currentY = self.state.chatContainer.currentY + 80
        
        -- Simple auto-scroll
        if self.state.chatContainer.currentY > self.state.chatContainer.maxY then
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

-- Update status with instance scope
function UIManager:updateStatus(text)
    if self.state.statusLabel and text then
        self.state.statusLabel.text = text
    end
end

-- Update memory stats with instance scope
function UIManager:updateMemoryStats(stats)
    if self.state.memoryLabel and stats then
        self.state.memoryLabel.text = "Memory: " .. (stats.conversationCount or 0) .. " conversations"
    end
end

-- Handle send button with instance scope
function UIManager:handleSend()
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

-- Handle clear memory with instance scope
function UIManager:handleClearMemory()
    -- Clear chat display
    if self.state.chatContainer and self.state.chatContainer.messagesGroup then
        self.state.chatContainer.messagesGroup:removeSelf()
        self.state.chatContainer.messagesGroup = display.newGroup()
        if self.state.chatContainer.messagesGroup then
            self.state.chatContainer.messagesGroup.x = self.state.chatContainer.x
            self.state.chatContainer.messagesGroup.y = self.state.chatContainer.y
            self.state.chatContainer:insert(self.state.chatContainer.messagesGroup)
            self.state.chatContainer.currentY = 10
        end
    end
    
    -- Reset demo counter
    self.state.demoCounter = 0
    
    -- Update displays
    self:updateStatus("Memory cleared - AI Assistant Ready")
    self:updateMemoryStats({conversationCount = 0})
end

-- Cleanup function with instance scope
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