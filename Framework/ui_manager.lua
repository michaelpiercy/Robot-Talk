-- UI Manager for Caleb's AI Assistant
-- Expert-level Solar2D implementation with comprehensive error handling

local UIManager = {}

-- UI Elements
local chatContainer
local inputField
local sendButton
local statusLabel
local memoryLabel
local clearButton

-- Dialog state management
local activeDialog = nil
local dialogElements = {}

-- Chat bubble styling
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

-- Safe cleanup dialog elements
local function cleanupDialog()
    if activeDialog then
        for _, element in ipairs(dialogElements) do
            safeRemove(element)
        end
        dialogElements = {}
        activeDialog = nil
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

-- Show text input dialog for simulator
function UIManager:showTextInputDialog()
    -- Prevent multiple dialogs
    if activeDialog then
        print("Warning: Dialog already active")
        return
    end
    
    activeDialog = true
    dialogElements = {}
    
    -- Create dialog background
    local dialogBg = display.newRoundedRect(display.actualContentWidth/2, display.actualContentHeight/2, 300, 150, 20)
    if dialogBg then
        dialogBg:setFillColor(1, 1, 1, 0.95)
        dialogBg:setStrokeColor(0.7, 0.7, 0.7, 1)
        dialogBg.strokeWidth = 2
        table.insert(dialogElements, dialogBg)
    end
    
    -- Create title
    local title = display.newText({
        text = "Enter your message:",
        x = display.actualContentWidth/2,
        y = display.actualContentHeight/2 - 40,
        font = native.systemFont,
        fontSize = 16
    })
    if title then
        title:setFillColor(0.2, 0.2, 0.2, 1)
        table.insert(dialogElements, title)
    end
    
    -- Create input field for dialog
    local dialogInput = nil
    local success, result = pcall(function()
        dialogInput = native.newTextField(display.actualContentWidth/2, display.actualContentHeight/2, 250, 30)
        if dialogInput then
            dialogInput.placeholder = "Type here..."
            dialogInput.font = native.newFont(native.systemFont, 14)
            dialogInput:setTextColor(0, 0, 0, 1)
            table.insert(dialogElements, dialogInput)
        end
        return dialogInput
    end)
    
    if not success or not dialogInput then
        print("Warning: Failed to create dialog input field")
        cleanupDialog()
        return
    end
    
    -- Create send button
    local sendBtn = display.newRoundedRect(display.actualContentWidth/2 + 80, display.actualContentHeight/2 + 30, 60, 30, 15)
    if sendBtn then
        sendBtn:setFillColor(0.2, 0.6, 1.0, 0.9)
        table.insert(dialogElements, sendBtn)
    end
    
    local sendText = display.newText({
        text = "Send",
        x = sendBtn and sendBtn.x or display.actualContentWidth/2 + 80,
        y = sendBtn and sendBtn.y or display.actualContentHeight/2 + 30,
        font = native.systemFont,
        fontSize = 12
    })
    if sendText then
        sendText:setFillColor(1, 1, 1, 1)
        table.insert(dialogElements, sendText)
    end
    
    -- Create cancel button
    local cancelBtn = display.newRoundedRect(display.actualContentWidth/2 - 80, display.actualContentHeight/2 + 30, 60, 30, 15)
    if cancelBtn then
        cancelBtn:setFillColor(0.7, 0.7, 0.7, 0.9)
        table.insert(dialogElements, cancelBtn)
    end
    
    local cancelText = display.newText({
        text = "Cancel",
        x = cancelBtn and cancelBtn.x or display.actualContentWidth/2 - 80,
        y = cancelBtn and cancelBtn.y or display.actualContentHeight/2 + 30,
        font = native.systemFont,
        fontSize = 12
    })
    if cancelText then
        cancelText:setFillColor(1, 1, 1, 1)
        table.insert(dialogElements, cancelText)
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
            cleanupDialog()
        end)
    end
    
    -- Handle cancel button
    if cancelBtn then
        cancelBtn:addEventListener("tap", function()
            cleanupDialog()
        end)
    end
end

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
    
    -- Process with LLM
    local success, LLMCore = pcall(require, "Definitions.llm_core")
    if success then
        -- Process input with AI robot for visual feedback
        if self.aiRobot and self.aiRobot.processInput then
            local robotSuccess, robotErr = pcall(function()
                self.aiRobot:processInput(sanitizedText)
            end)
            if not robotSuccess then
                print("Warning: Robot processing failed:", robotErr)
            end
        end
        
        -- Generate response
        local responseSuccess, response = pcall(function()
            return LLMCore:processInput(sanitizedText)
        end)
        
        if responseSuccess and response then
            -- Add AI response to chat
            self:addChatBubble(response, false)
            
            -- Update memory stats
            local statsSuccess, stats = pcall(function()
                return LLMCore:getMemoryStats()
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

-- Initialize UI Manager
function UIManager:new()
    local ui = {}
    setmetatable(ui, { __index = UIManager })
    return ui
end

-- Initialize the UI
function UIManager:init()
    print("Initializing UI Manager...")
    
    -- Get display dimensions
    local _w = display.actualContentWidth
    local _h = display.actualContentHeight
    
    if not _w or not _h then
        print("Error: Invalid display dimensions")
        return false
    end
    
    self:createChatContainer(_w, _h)
    self:createInputArea(_w, _h)
    self:createStatusBar(_w, _h)
    self:createMemoryDisplay(_w, _h)
    
    print("UI Manager initialized successfully!")
    return true
end

-- Create chat container
function UIManager:createChatContainer(_w, _h)
    if not _w or not _h then
        print("Error: Invalid dimensions for chat container")
        return
    end
    
    chatContainer = display.newGroup()
    if not chatContainer then
        print("Error: Failed to create chat container")
        return
    end
    
    chatContainer.x = _w/2
    chatContainer.y = _h/2 - 100
    chatContainer.width = _w - 40
    chatContainer.height = _h - 200
    
    -- Create chat background
    local chatBackground = display.newRoundedRect(chatContainer.x, chatContainer.y, chatContainer.width, chatContainer.height, 10)
    if chatBackground then
        chatBackground:setFillColor(0.95, 0.95, 0.95, 0.3)
        chatBackground:setStrokeColor(0.8, 0.8, 0.8, 0.5)
        chatBackground.strokeWidth = 1
        chatContainer:insert(chatBackground)
    end
    
    -- Create messages group
    chatContainer.messagesGroup = display.newGroup()
    if chatContainer.messagesGroup then
        chatContainer.messagesGroup.x = chatContainer.x
        chatContainer.messagesGroup.y = chatContainer.y
        chatContainer.messagesGroup.width = chatContainer.width - 20
        chatContainer.messagesGroup.height = chatContainer.height - 20
        chatContainer:insert(chatContainer.messagesGroup)
    end
    
    -- Initialize message tracking
    chatContainer.currentY = 10
    chatContainer.maxY = chatContainer.height - 20
end

-- Create input area
function UIManager:createInputArea(_w, _h)
    if not _w or not _h then
        print("Error: Invalid dimensions for input area")
        return
    end
    
    -- Input background
    local inputBg = display.newRoundedRect(_w/2, _h - 80, _w - 120, 50, 25)
    if inputBg then
        inputBg:setFillColor(0.9, 0.9, 0.9, 0.8)
        inputBg:setStrokeColor(0.7, 0.7, 0.7, 1)
        inputBg.strokeWidth = 2
    end
    
    -- Create proper text input field for Solar2D simulator
    local success, result = pcall(function()
        inputField = native.newTextField(_w/2, _h - 80, _w - 160, 40)
        if inputField then
            inputField.placeholder = "Type your message here..."
            inputField.font = native.newFont(native.systemFont, 16)
            inputField:addEventListener("userInput", function(event)
                if event.phase == "submitted" then
                    self:handleSend()
                end
            end)
        end
        return inputField
    end)
    
    if not success or not inputField then
        print("Warning: Native text field not available, using fallback")
        -- Create a clickable text input simulation
        inputField = display.newText({
            text = "Click to type message",
            x = _w/2,
            y = _h - 80,
            font = native.systemFont,
            fontSize = 16
        })
        if inputField then
            inputField:setFillColor(0.5, 0.5, 0.5, 1)
            inputField.text = ""
            inputField.isSimulated = true
            
            -- Add tap handler for simulated input
            inputField:addEventListener("tap", function()
                self:showTextInputDialog()
            end)
        end
    end
    
    -- Send button
    sendButton = display.newRoundedRect(_w - 60, _h - 80, 50, 40, 20)
    if sendButton then
        sendButton:setFillColor(0.2, 0.6, 1.0, 0.9)
        sendButton:setStrokeColor(0.1, 0.4, 0.8, 1)
        sendButton.strokeWidth = 2
        
        local sendText = display.newText({
            text = "Send",
            x = sendButton.x,
            y = sendButton.y,
            font = native.systemFont,
            fontSize = 14
        })
        if sendText then
            sendText:setFillColor(1, 1, 1, 1)
        end
        
        sendButton:addEventListener("tap", function()
            self:handleSend()
        end)
    end
end

-- Create status bar
function UIManager:createStatusBar(_w, _h)
    if not _w or not _h then
        print("Error: Invalid dimensions for status bar")
        return
    end
    
    statusLabel = display.newText({
        text = "AI Assistant Ready",
        x = 20,
        y = 40,
        font = native.systemFont,
        fontSize = 14,
        align = "left"
    })
    if statusLabel then
        statusLabel:setFillColor(0.3, 0.3, 0.3, 1)
        statusLabel.anchorX = 0
    end
end

-- Create memory display
function UIManager:createMemoryDisplay(_w, _h)
    if not _w or not _h then
        print("Error: Invalid dimensions for memory display")
        return
    end
    
    memoryLabel = display.newText({
        text = "Memory: 0 conversations",
        x = _w - 20,
        y = 40,
        font = native.systemFont,
        fontSize = 12,
        align = "right"
    })
    if memoryLabel then
        memoryLabel:setFillColor(0.5, 0.5, 0.5, 1)
        memoryLabel.anchorX = 1
    end
    
    -- Clear memory button
    clearButton = display.newRoundedRect(_w - 100, 60, 80, 25, 12)
    if clearButton then
        clearButton:setFillColor(0.8, 0.3, 0.3, 0.8)
        
        local clearText = display.newText({
            text = "Clear",
            x = clearButton.x,
            y = clearButton.y,
            font = native.systemFont,
            fontSize = 12
        })
        if clearText then
            clearText:setFillColor(1, 1, 1, 1)
        end
        
        clearButton:addEventListener("tap", function()
            self:handleClearMemory()
        end)
    end
end

-- Add chat bubble
function UIManager:addChatBubble(text, isUser)
    if not text then
        print("Error: No text provided for chat bubble")
        return
    end
    
    if not chatContainer or not chatContainer.messagesGroup then
        print("Error: Chat container not initialized")
        return
    end
    
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
            bubbleGroup.x = chatContainer.width - bubble.width/2 - 20
        else
            bubbleGroup.x = bubble.width/2 + 20
        end
        
        -- Position vertically
        bubbleGroup.y = chatContainer.currentY + 30
        
        -- Add to messages group
        chatContainer.messagesGroup:insert(bubbleGroup)
        
        -- Update current Y position
        chatContainer.currentY = chatContainer.currentY + 80
        
        -- Simple auto-scroll
        if chatContainer.currentY > chatContainer.maxY then
            for i = 1, chatContainer.messagesGroup.numChildren do
                local child = chatContainer.messagesGroup[i]
                if child and child.y then
                    child.y = child.y - 80
                end
            end
            chatContainer.currentY = chatContainer.currentY - 80
        end
        
        return bubbleGroup
    end
end

-- Update status
function UIManager:updateStatus(text)
    if statusLabel and text then
        statusLabel.text = text
    end
end

-- Update memory stats
function UIManager:updateMemoryStats(stats)
    if memoryLabel and stats then
        memoryLabel.text = "Memory: " .. (stats.conversationCount or 0) .. " conversations"
    end
end

-- Handle send button
function UIManager:handleSend()
    -- Check if we have a real text field
    if inputField and inputField.text then
        local text = inputField.text
        local isValid, sanitizedText = validateInput(text)
        
        if isValid then
            self:processUserInput(sanitizedText)
            -- Clear the input field
            inputField.text = ""
            if inputField.setText then
                inputField:setText("")
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
        
        local demoIndex = (self.demoCounter or 0) % #demoMessages + 1
        local text = demoMessages[demoIndex]
        self.demoCounter = (self.demoCounter or 0) + 1
        
        if text and text ~= "" then
            self:processUserInput(text)
        end
    end
end

-- Handle clear memory
function UIManager:handleClearMemory()
    -- Clear chat display
    if chatContainer and chatContainer.messagesGroup then
        chatContainer.messagesGroup:removeSelf()
        chatContainer.messagesGroup = display.newGroup()
        if chatContainer.messagesGroup then
            chatContainer.messagesGroup.x = chatContainer.x
            chatContainer.messagesGroup.y = chatContainer.y
            chatContainer:insert(chatContainer.messagesGroup)
            chatContainer.currentY = 10
        end
    end
    
    -- Reset demo counter
    self.demoCounter = 0
    
    -- Update displays
    self:updateStatus("Memory cleared - AI Assistant Ready")
    self:updateMemoryStats({conversationCount = 0})
end

return UIManager