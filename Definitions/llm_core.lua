---@meta
---@diagnostic disable: undefined-global

-- LLM Core Module for Caleb's AI Assistant
-- Expert-level Solar2D implementation with comprehensive error handling

---@class LLMCore
---@field conversationHistory ConversationEntry[] Array of conversation history entries
---@field contextMemory table<string, ContextEntry> Context memory storage
---@field userPreferences table<string, PreferenceEntry> User preference storage
---@field conversationCount number Total number of conversations processed
---@field debugMode boolean Whether debug mode is enabled

local LLMCore = {}

-- ============================================================================
-- MEMORY & STATE MANAGEMENT
-- ============================================================================

---@class ConversationEntry
---@field input string The user input text
---@field response string The AI response text
---@field analysis InputAnalysis The analysis of the input
---@field timestamp number The timestamp when the entry was created

---@class ContextEntry
---@field value any The context value
---@field timestamp number The timestamp when the context was stored

---@class PreferenceEntry
---@field value any The preference value
---@field timestamp number The timestamp when the preference was stored

---@class InputAnalysis
---@field intent string The detected intent
---@field sentiment string The detected sentiment
---@field keywords string[] The extracted keywords
---@field confidence number The confidence level (0-1)

---@class Context
---@field lastTopic string|nil The last topic discussed
---@field conversationLength number The length of the conversation
---@field userMood string The detected user mood
---@field commonTopics string[] Array of common topics

-- Memory and state management
---@type ConversationEntry[]
local conversationHistory = {}
---@type table<string, ContextEntry>
local contextMemory = {}
---@type table<string, PreferenceEntry>
local userPreferences = {}
---@type number
local conversationCount = 0
---@type boolean
local debugMode = false

-- ============================================================================
-- RESPONSE PATTERNS
-- ============================================================================

---@type table<string, string[]> Response patterns for different intents
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

-- ============================================================================
-- SAFETY & UTILITY FUNCTIONS
-- ============================================================================

---Safe module loading function
---@param modulePath string The path to the module to load
---@return any|nil The loaded module or nil if failed
local function safeRequire(modulePath)
    local success, result = pcall(require, modulePath)
    if success then
        return result
    else
        print("Warning: Failed to load module:", modulePath, "-", result)
        return nil
    end
end

---Input validation function
---@param input string|nil The input to validate
---@return boolean valid Whether the input is valid
---@return string|string sanitized The sanitized input or error message
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

---Debug print function
---@param message string The debug message to print
local function debugPrint(message)
    if debugMode then
        print("[LLM DEBUG] " .. message)
    end
end

-- ============================================================================
-- CORE LLM FUNCTIONALITY
-- ============================================================================

---Analyze input for intent and sentiment
---@param input string|nil The input text to analyze
---@return InputAnalysis The analysis result
function LLMCore:analyzeInput(input)
    if not input then
        debugPrint("Warning: No input provided for analysis")
        return {
            intent = "confusion",
            sentiment = "neutral",
            keywords = {},
            confidence = 0
        }
    end
    
    debugPrint("Analyzing input: " .. input)
    
    local inputLower = string.lower(input)
    ---@type InputAnalysis
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
    
    debugPrint("Extracted keywords: " .. table.concat(words, ", "))
    
    -- Detect intent
    ---@type string[]
    local greetingWords = {"hello", "hi", "hey", "greetings", "good morning", "good afternoon", "good evening"}
    ---@type string[]
    local farewellWords = {"goodbye", "bye", "see you", "farewell", "later", "good night"}
    ---@type string[]
    local questionWords = {"what", "how", "why", "when", "where", "who", "which", "?"}
    
    for _, word in ipairs(greetingWords) do
        if string.find(inputLower, word) then
            analysis.intent = "greeting"
            analysis.confidence = 0.8
            debugPrint("Detected intent: greeting")
            break
        end
    end
    
    for _, word in ipairs(farewellWords) do
        if string.find(inputLower, word) then
            analysis.intent = "farewell"
            analysis.confidence = 0.8
            debugPrint("Detected intent: farewell")
            break
        end
    end
    
    for _, word in ipairs(questionWords) do
        if string.find(inputLower, word) then
            analysis.intent = "question"
            analysis.confidence = 0.7
            debugPrint("Detected intent: question")
            break
        end
    end
    
    -- Analyze sentiment
    ---@type string[]
    local positiveWords = {"good", "great", "awesome", "excellent", "amazing", "love", "like", "happy", "excited", "wonderful", "fantastic"}
    ---@type string[]
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
        debugPrint("Detected sentiment: positive")
    elseif negativeCount > positiveCount then
        analysis.sentiment = "negative"
        debugPrint("Detected sentiment: negative")
    else
        debugPrint("Detected sentiment: neutral")
    end
    
    debugPrint("Analysis complete - Intent: " .. analysis.intent .. ", Sentiment: " .. analysis.sentiment .. ", Confidence: " .. analysis.confidence)
    
    return analysis
end

---Generate response based on intent and context
---@param analysis InputAnalysis The input analysis
---@param context Context|nil The conversation context
---@return string The generated response
function LLMCore:generateResponse(analysis, context)
    if not analysis or not analysis.intent then
        debugPrint("Warning: Invalid analysis for response generation")
        return "I'm here to help!"
    end
    
    debugPrint("Generating response for intent: " .. analysis.intent)
    
    local response = ""
    
    -- Try to get knowledge-based response first
    local KnowledgeBase = safeRequire("Definitions.knowledge_base")
    if KnowledgeBase then
        debugPrint("Knowledge Base available, attempting intelligent response")
        local knowledgeResponse = KnowledgeBase:generateIntelligentResponse(analysis.keywords)
        if knowledgeResponse and knowledgeResponse ~= "" then
            response = knowledgeResponse
            debugPrint("Knowledge-based response generated: " .. response)
        else
            debugPrint("No knowledge-based response found")
        end
    else
        debugPrint("Knowledge Base not available")
    end
    
    -- Fallback to pattern-based response
    if response == "" then
        debugPrint("Using pattern-based response")
        local patterns = responsePatterns[analysis.intent]
        if patterns and #patterns > 0 then
            response = patterns[math.random(1, #patterns)]
            debugPrint("Pattern-based response selected: " .. response)
        else
            response = "I understand what you're saying."
            debugPrint("Default response used")
        end
    end
    
    -- Add context-aware elements
    if context and context.lastTopic then
        response = response .. " Regarding " .. context.lastTopic .. ", "
        debugPrint("Added context-aware element")
    end
    
    debugPrint("Final response: " .. response)
    return response
end

---Get context from conversation history
---@return Context The conversation context
function LLMCore:getContext()
    ---@type Context
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
            debugPrint("Last topic: " .. (context.lastTopic or "none"))
        end
    end
    
    -- Analyze common topics
    ---@type table<string, number>
    local topicCount = {}
    for _, message in ipairs(conversationHistory) do
        if message.keywords then
            for _, keyword in ipairs(message.keywords) do
                topicCount[keyword] = (topicCount[keyword] or 0) + 1
            end
        end
    end
    
    -- Get top 3 topics
    ---@type {topic: string, count: number}[]
    local topics = {}
    for topic, count in pairs(topicCount) do
        table.insert(topics, {topic = topic, count = count})
    end
    table.sort(topics, function(a, b) return a.count > b.count end)
    
    for i = 1, math.min(3, #topics) do
        table.insert(context.commonTopics, topics[i].topic)
    end
    
    debugPrint("Context - Conversation length: " .. context.conversationLength .. ", Common topics: " .. table.concat(context.commonTopics, ", "))
    
    return context
end

---Process user input and generate response
---@param input string The user input text
---@return string The generated response
function LLMCore:processInput(input)
    debugPrint("Processing input: " .. input)
    
    local isValid, sanitizedInput = validateInput(input)
    if not isValid then
        debugPrint("Input validation failed: " .. sanitizedInput)
        return "I didn't understand that. Could you please rephrase?"
    end
    
    -- Analyze input
    local analysis = self:analyzeInput(sanitizedInput)
    
    -- Get context
    local context = self:getContext()
    
    -- Generate response
    local response = self:generateResponse(analysis, context)
    
    -- Store in conversation history
    ---@type ConversationEntry
    local entry = {
        input = sanitizedInput,
        response = response,
        analysis = analysis,
        timestamp = os.time()
    }
    table.insert(conversationHistory, entry)
    
    -- Update conversation count
    conversationCount = conversationCount + 1
    
    -- Limit history size
    if #conversationHistory > 50 then
        table.remove(conversationHistory, 1)
    end
    
    debugPrint("Conversation stored - Total conversations: " .. conversationCount .. ", History size: " .. #conversationHistory)
    
    return response
end

---Get conversation history
---@return ConversationEntry[] The conversation history
function LLMCore:getConversationHistory()
    return conversationHistory
end

---Clear memory
function LLMCore:clearMemory()
    conversationHistory = {}
    contextMemory = {}
    userPreferences = {}
    conversationCount = 0
    debugPrint("Memory cleared successfully")
    print("Memory cleared successfully")
end

---Get memory statistics
---@return {conversationCount: number, historySize: number, contextSize: number, preferencesSize: number} The memory statistics
function LLMCore:getMemoryStats()
    local stats = {
        conversationCount = conversationCount,
        historySize = #conversationHistory,
        contextSize = #contextMemory,
        preferencesSize = #userPreferences
    }
    debugPrint("Memory stats - Conversations: " .. stats.conversationCount .. ", History: " .. stats.historySize)
    return stats
end

---Add to context memory
---@param key string The context key
---@param value any The context value
---@return boolean success Whether the context was added successfully
function LLMCore:addToContext(key, value)
    if not key or not value then
        debugPrint("Warning: Invalid context data")
        return false
    end
    
    ---@type ContextEntry
    contextMemory[key] = {
        value = value,
        timestamp = os.time()
    }
    
    debugPrint("Context added: " .. key .. " = " .. tostring(value))
    return true
end

---Get from context memory
---@param key string The context key
---@return any|nil The context value or nil if not found
function LLMCore:getFromContext(key)
    if not key then
        return nil
    end
    
    local context = contextMemory[key]
    if context then
        debugPrint("Context retrieved: " .. key .. " = " .. tostring(context.value))
        return context.value
    end
    
    debugPrint("Context not found: " .. key)
    return nil
end

---Add user preference
---@param preference string The preference key
---@param value any The preference value
---@return boolean success Whether the preference was added successfully
function LLMCore:addUserPreference(preference, value)
    if not preference or not value then
        debugPrint("Warning: Invalid preference data")
        return false
    end
    
    ---@type PreferenceEntry
    userPreferences[preference] = {
        value = value,
        timestamp = os.time()
    }
    
    debugPrint("Preference added: " .. preference .. " = " .. tostring(value))
    return true
end

---Get user preference
---@param preference string The preference key
---@return any|nil The preference value or nil if not found
function LLMCore:getUserPreference(preference)
    if not preference then
        return nil
    end
    
    local pref = userPreferences[preference]
    if pref then
        debugPrint("Preference retrieved: " .. preference .. " = " .. tostring(pref.value))
        return pref.value
    end
    
    debugPrint("Preference not found: " .. preference)
    return nil
end

---Set debug mode
---@param enabled boolean Whether to enable debug mode
function LLMCore:setDebugMode(enabled)
    debugMode = enabled
    debugPrint("Debug mode " .. (enabled and "enabled" or "disabled"))
end

---Constructor
---@return LLMCore The new LLM core instance
function LLMCore:new()
    local llm = {}
    setmetatable(llm, { __index = LLMCore })
    
    -- Enable debug mode by default
    llm:setDebugMode(true)
    
    return llm
end

return LLMCore