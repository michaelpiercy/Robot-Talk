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

function UIManager:init()
    self:createChatContainer()
    self:createInputArea()
    self:createStatusBar()
    self:createMemoryDisplay()
end

function UIManager:createChatContainer()
    chatContainer = display.newGroup()
    chatContainer.x = _w/2
    chatContainer.y = _h/2 - 100
    chatContainer.width = _w - 40
    chatContainer.height = _h - 200
    
    -- Add scroll view for chat messages
    local scrollView = widget.newScrollView({
        top = chatContainer.y - chatContainer.height/2,
        left = chatContainer.x - chatContainer.width/2,
        width = chatContainer.width,
        height = chatContainer.height,
        scrollWidth = chatContainer.width,
        scrollHeight = chatContainer.height,
        backgroundColor = {0.95, 0.95, 0.95, 0.3}
    })
    chatContainer.scrollView = scrollView
end

function UIManager:createInputArea()
    -- Input field background
    local inputBg = display.newRoundedRect(_w/2, _h - 80, _w - 120, 50, 25)
    inputBg:setFillColor(0.9, 0.9, 0.9, 0.8)
    inputBg:setStrokeColor(0.7, 0.7, 0.7, 1)
    inputBg.strokeWidth = 2
    
    -- Text input field
    inputField = native.newTextField(_w/2, _h - 80, _w - 160, 40)
    inputField.placeholder = "Type your message here..."
    inputField.font = native.newFont(native.systemFont, 16)
    inputField:addEventListener("userInput", self.handleInput)
    
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
    
    sendButton:addEventListener("tap", self.handleSend)
end

function UIManager:createStatusBar()
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

function UIManager:createMemoryDisplay()
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
    
    clearButton:addEventListener("tap", self.handleClearMemory)
end

function UIManager:addChatBubble(text, isUser)
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
    
    -- Add to scroll view
    chatContainer.scrollView:insert(bubbleGroup)
    
    -- Scroll to bottom
    timer.performWithDelay(100, function()
        chatContainer.scrollView:scrollToPosition({
            y = chatContainer.scrollView.contentHeight,
            time = 300
        })
    end)
    
    return bubbleGroup
end

function UIManager:updateStatus(text)
    statusLabel.text = text
end

function UIManager:updateMemoryStats(stats)
    memoryLabel.text = "Memory: " .. stats.conversationCount .. " conversations"
end

function UIManager:handleInput(event)
    if event.phase == "submitted" then
        self:handleSend()
    end
end

function UIManager:handleSend()
    local text = inputField.text
    if text and text ~= "" then
        -- Add user message to chat
        self:addChatBubble(text, true)
        
        -- Clear input field
        inputField.text = ""
        
        -- Update status to show processing
        self:updateStatus("AI Assistant - Processing...")
        
        -- Process with LLM
        local LLMCore = require("Definitions.llm_core")
        
        -- Process input with AI robot for visual feedback
        if self.aiRobot then
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
        self:updateStatus("AI Assistant - " .. stats.conversationCount .. " messages")
    end
end

function UIManager:handleClearMemory()
    local LLMCore = require("Definitions.llm_core")
    LLMCore:clearMemory()
    
    -- Clear chat display
    chatContainer.scrollView:removeSelf()
    self:createChatContainer()
    
    -- Update displays
    self:updateStatus("Memory cleared - AI Assistant Ready")
    self:updateMemoryStats({conversationCount = 0})
end

return UIManager