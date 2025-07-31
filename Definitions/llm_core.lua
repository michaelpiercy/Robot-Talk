-- LLM Core Module for Caleb's AI Assistant
-- Expert-level Solar2D implementation with comprehensive error handling

local LLMCore = {}

-- Memory and state management
local conversationHistory = {}
local contextMemory = {}
local userPreferences = {}
local conversationCount = 0

-- Response patterns for different intents
local responsePatterns = {
    greeting = {
        "Hello! How can I help you today?",
        "Hi there! What would you like to know?",
        "Greetings! I'm here to assist you.",
        "Welcome! How may I be of service?"
    },
    farewell = {
        "Goodbye! Have a great day!",
        "See you later! Feel free to ask more questions.",
        "Take care! I'm here when you need me.",
        "Farewell! Don't hesitate to return."
    },
    question = {
        "That's an interesting question!",
        "Let me think about that...",
        "Great question! Here's what I know:",
        "I'd be happy to help with that."
    },
    statement = {
        "I understand what you're saying.",
        "That's a good point!",
        "Thanks for sharing that.",
        "I see what you mean."
    },
    confusion = {
        "I'm not quite sure I understand. Could you clarify?",
        "That's a bit unclear to me. Can you explain more?",
        "I'd like to help, but I need more information.",
        "Could you rephrase that for me?"
    }
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

-- Input validation function
local function validateInput(input)
    if not input then return false, "No input provided" end
    if type(input) ~= "string" then return false, "Invalid input type" end
    if string.len(input) == 0 then return false, "Empty input" end
    if string.len(input) > 2000 then return false, "Input too long" end
    
    -- Sanitize input - remove dangerous characters
    local sanitized = string.gsub(input, "[<>\"']", "")
    if sanitized ~= input then
        print("Warning: Input sanitized")
    end
    
    return true, sanitized
end

-- Analyze input for intent and sentiment
function LLMCore:analyzeInput(input)
    if not input then
        print("Warning: No input provided for analysis")
        return {
            intent = "confusion",
            sentiment = "neutral",
            keywords = {},
            confidence = 0
        }
    end
    
    local inputLower = string.lower(input)
    local analysis = {
        intent = "statement",
        sentiment = "neutral",
        keywords = {},
        confidence = 0.5
    }
    
    -- Extract keywords
    local words = {}
    for word in string.gmatch(inputLower, "%w+") do
        if string.len(word) > 2 then
            table.insert(words, word)
        end
    end
    analysis.keywords = words
    
    -- Detect intent
    local greetingWords = {"hello", "hi", "hey", "greetings", "good morning", "good afternoon", "good evening"}
    local farewellWords = {"goodbye", "bye", "see you", "farewell", "later", "good night"}
    local questionWords = {"what", "how", "why", "when", "where", "who", "which", "?"}
    
    for _, word in ipairs(greetingWords) do
        if string.find(inputLower, word) then
            analysis.intent = "greeting"
            analysis.confidence = 0.8
            break
        end
    end
    
    for _, word in ipairs(farewellWords) do
        if string.find(inputLower, word) then
            analysis.intent = "farewell"
            analysis.confidence = 0.8
            break
        end
    end
    
    for _, word in ipairs(questionWords) do
        if string.find(inputLower, word) then
            analysis.intent = "question"
            analysis.confidence = 0.7
            break
        end
    end
    
    -- Analyze sentiment
    local positiveWords = {"good", "great", "awesome", "excellent", "amazing", "love", "like", "happy", "excited", "wonderful", "fantastic"}
    local negativeWords = {"bad", "terrible", "awful", "hate", "dislike", "sad", "angry", "frustrated", "horrible", "worst"}
    
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
        analysis.sentiment = "positive"
    elseif negativeCount > positiveCount then
        analysis.sentiment = "negative"
    end
    
    return analysis
end

-- Generate response based on intent and context
function LLMCore:generateResponse(analysis, context)
    if not analysis or not analysis.intent then
        print("Warning: Invalid analysis for response generation")
        return "I'm here to help!"
    end
    
    local response = ""
    
    -- Try to get knowledge-based response first
    local KnowledgeBase = safeRequire("Definitions.knowledge_base")
    if KnowledgeBase then
        local knowledgeResponse = KnowledgeBase:generateIntelligentResponse(analysis.keywords)
        if knowledgeResponse and knowledgeResponse ~= "" then
            response = knowledgeResponse
        end
    end
    
    -- Fallback to pattern-based response
    if response == "" then
        local patterns = responsePatterns[analysis.intent]
        if patterns and #patterns > 0 then
            response = patterns[math.random(1, #patterns)]
        else
            response = "I understand what you're saying."
        end
    end
    
    -- Add context-aware elements
    if context and context.lastTopic then
        response = response .. " Regarding " .. context.lastTopic .. ", "
    end
    
    return response
end

-- Get context from conversation history
function LLMCore:getContext()
    local context = {
        lastTopic = nil,
        conversationLength = #conversationHistory,
        userMood = "neutral",
        commonTopics = {}
    }
    
    if #conversationHistory > 0 then
        local lastMessage = conversationHistory[#conversationHistory]
        if lastMessage and lastMessage.keywords then
            context.lastTopic = lastMessage.keywords[1]
        end
    end
    
    -- Analyze common topics
    local topicCount = {}
    for _, message in ipairs(conversationHistory) do
        if message.keywords then
            for _, keyword in ipairs(message.keywords) do
                topicCount[keyword] = (topicCount[keyword] or 0) + 1
            end
        end
    end
    
    -- Get top 3 topics
    local topics = {}
    for topic, count in pairs(topicCount) do
        table.insert(topics, {topic = topic, count = count})
    end
    table.sort(topics, function(a, b) return a.count > b.count end)
    
    for i = 1, math.min(3, #topics) do
        table.insert(context.commonTopics, topics[i].topic)
    end
    
    return context
end

-- Process user input and generate response
function LLMCore:processInput(input)
    local isValid, sanitizedInput = validateInput(input)
    if not isValid then
        print("Input validation failed:", sanitizedInput)
        return "I didn't understand that. Could you please rephrase?"
    end
    
    -- Analyze input
    local analysis = self:analyzeInput(sanitizedInput)
    
    -- Get context
    local context = self:getContext()
    
    -- Generate response
    local response = self:generateResponse(analysis, context)
    
    -- Store in conversation history
    table.insert(conversationHistory, {
        input = sanitizedInput,
        response = response,
        analysis = analysis,
        timestamp = os.time()
    })
    
    -- Update conversation count
    conversationCount = conversationCount + 1
    
    -- Limit history size
    if #conversationHistory > 50 then
        table.remove(conversationHistory, 1)
    end
    
    return response
end

-- Get conversation history
function LLMCore:getConversationHistory()
    return conversationHistory
end

-- Clear memory
function LLMCore:clearMemory()
    conversationHistory = {}
    contextMemory = {}
    userPreferences = {}
    conversationCount = 0
    print("Memory cleared successfully")
end

-- Get memory statistics
function LLMCore:getMemoryStats()
    return {
        conversationCount = conversationCount,
        historySize = #conversationHistory,
        contextSize = #contextMemory,
        preferencesSize = #userPreferences
    }
end

-- Add to context memory
function LLMCore:addToContext(key, value)
    if not key or not value then
        print("Warning: Invalid context data")
        return false
    end
    
    contextMemory[key] = {
        value = value,
        timestamp = os.time()
    }
    
    return true
end

-- Get from context memory
function LLMCore:getFromContext(key)
    if not key then
        return nil
    end
    
    local context = contextMemory[key]
    if context then
        return context.value
    end
    
    return nil
end

-- Add user preference
function LLMCore:addUserPreference(preference, value)
    if not preference or not value then
        print("Warning: Invalid preference data")
        return false
    end
    
    userPreferences[preference] = {
        value = value,
        timestamp = os.time()
    }
    
    return true
end

-- Get user preference
function LLMCore:getUserPreference(preference)
    if not preference then
        return nil
    end
    
    local pref = userPreferences[preference]
    if pref then
        return pref.value
    end
    
    return nil
end

-- Constructor
function LLMCore:new()
    local llm = {}
    setmetatable(llm, { __index = LLMCore })
    return llm
end

return LLMCore