-- UI Manager for Caleb's AI Assistant
-- Solar2D compatible implementation

local UIManager = {}

-- UI Elements
local chatContainer
local inputField
local sendButton
local statusLabel
local memoryLabel
local clearButton

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
    
    self:createChatContainer(_w, _h)
    self:createInputArea(_w, _h)
    self:createStatusBar(_w, _h)
    self:createMemoryDisplay(_w, _h)
    
    print("UI Manager initialized successfully!")
end

-- Create chat container
function UIManager:createChatContainer(_w, _h)
    chatContainer = display.newGroup()
    chatContainer.x = _w/2
    chatContainer.y = _h/2 - 100
    chatContainer.width = _w - 40
    chatContainer.height = _h - 200
    
    -- Create chat background
    local chatBackground = display.newRoundedRect(chatContainer.x, chatContainer.y, chatContainer.width, chatContainer.height, 10)
    chatBackground:setFillColor(0.95, 0.95, 0.95, 0.3)
    chatBackground:setStrokeColor(0.8, 0.8, 0.8, 0.5)
    chatBackground.strokeWidth = 1
    
    -- Create messages group
    chatContainer.messagesGroup = display.newGroup()
    chatContainer.messagesGroup.x = chatContainer.x
    chatContainer.messagesGroup.y = chatContainer.y
    chatContainer.messagesGroup.width = chatContainer.width - 20
    chatContainer.messagesGroup.height = chatContainer.height - 20
    
    -- Add to chat container
    chatContainer:insert(chatBackground)
    chatContainer:insert(chatContainer.messagesGroup)
    
    -- Initialize message tracking
    chatContainer.currentY = 10
    chatContainer.maxY = chatContainer.height - 20
end

-- Create input area
function UIManager:createInputArea(_w, _h)
    -- Input background
    local inputBg = display.newRoundedRect(_w/2, _h - 80, _w - 120, 50, 25)
    inputBg:setFillColor(0.9, 0.9, 0.9, 0.8)
    inputBg:setStrokeColor(0.7, 0.7, 0.7, 1)
    inputBg.strokeWidth = 2
    
    -- Create simple text display for input (fallback)
    inputField = display.newText({
        text = "Tap to send demo message",
        x = _w/2,
        y = _h - 80,
        font = native.systemFont,
        fontSize = 16
    })
    inputField:setFillColor(0.5, 0.5, 0.5, 1)
    inputField.text = ""
    
    -- Add tap handler for demo mode
    inputField:addEventListener("tap", function()
        self:handleSend()
    end)
    
    -- Send button
    sendButton = display.newRoundedRect(_w - 60, _h - 80, 50, 40, 20)
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
    sendText:setFillColor(1, 1, 1, 1)
    
    sendButton:addEventListener("tap", function()
        self:handleSend()
    end)
end

-- Create status bar
function UIManager:createStatusBar(_w, _h)
    statusLabel = display.newText({
        text = "AI Assistant Ready",
        x = 20,
        y = 40,
        font = native.systemFont,
        fontSize = 14,
        align = "left"
    })
    statusLabel:setFillColor(0.3, 0.3, 0.3, 1)
    statusLabel.anchorX = 0
end

-- Create memory display
function UIManager:createMemoryDisplay(_w, _h)
    memoryLabel = display.newText({
        text = "Memory: 0 conversations",
        x = _w - 20,
        y = 40,
        font = native.systemFont,
        fontSize = 12,
        align = "right"
    })
    memoryLabel:setFillColor(0.5, 0.5, 0.5, 1)
    memoryLabel.anchorX = 1
    
    -- Clear memory button
    clearButton = display.newRoundedRect(_w - 100, 60, 80, 25, 12)
    clearButton:setFillColor(0.8, 0.3, 0.3, 0.8)
    
    local clearText = display.newText({
        text = "Clear",
        x = clearButton.x,
        y = clearButton.y,
        font = native.systemFont,
        fontSize = 12
    })
    clearText:setFillColor(1, 1, 1, 1)
    
    clearButton:addEventListener("tap", function()
        self:handleClearMemory()
    end)
end

-- Add chat bubble
function UIManager:addChatBubble(text, isUser)
    if not chatContainer or not chatContainer.messagesGroup then
        print("Error: Chat container not initialized")
        return
    end
    
    local style = isUser and bubbleStyle.userBubble or bubbleStyle.aiBubble
    
    -- Create bubble background
    local bubble = display.newRoundedRect(0, 0, style.maxWidth, 60, style.cornerRadius)
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
    textObj:setFillColor(unpack(style.textColor))
    
    -- Group bubble and text
    local bubbleGroup = display.newGroup()
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
            if child.y then
                child.y = child.y - 80
            end
        end
        chatContainer.currentY = chatContainer.currentY - 80
    end
    
    return bubbleGroup
end

-- Update status
function UIManager:updateStatus(text)
    if statusLabel then
        statusLabel.text = text
    end
end

-- Update memory stats
function UIManager:updateMemoryStats(stats)
    if memoryLabel then
        memoryLabel.text = "Memory: " .. (stats.conversationCount or 0) .. " conversations"
    end
end

-- Handle send button
function UIManager:handleSend()
    -- Demo mode: cycle through sample messages
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
        -- Add user message to chat
        self:addChatBubble(text, true)
        
        -- Update status
        self:updateStatus("AI Assistant - Processing...")
        
        -- Process with LLM
        local success, LLMCore = pcall(require, "Definitions.llm_core")
        if success then
            -- Process input with AI robot for visual feedback
            if self.aiRobot and self.aiRobot.processInput then
                self.aiRobot:processInput(text)
            end
            
            -- Generate response
            local response = LLMCore:processInput(text)
            
            -- Add AI response to chat
            self:addChatBubble(response, false)
            
            -- Update memory stats
            local stats = LLMCore:getMemoryStats()
            self:updateMemoryStats(stats)
            
            -- Update status
            self:updateStatus("AI Assistant - " .. (stats.conversationCount or 0) .. " messages")
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
end

-- Handle clear memory
function UIManager:handleClearMemory()
    -- Clear chat display
    if chatContainer and chatContainer.messagesGroup then
        chatContainer.messagesGroup:removeSelf()
        chatContainer.messagesGroup = display.newGroup()
        chatContainer.messagesGroup.x = chatContainer.x
        chatContainer.messagesGroup.y = chatContainer.y
        chatContainer:insert(chatContainer.messagesGroup)
        chatContainer.currentY = 10
    end
    
    -- Reset demo counter
    self.demoCounter = 0
    
    -- Update displays
    self:updateStatus("Memory cleared - AI Assistant Ready")
    self:updateMemoryStats({conversationCount = 0})
end

return UIManager