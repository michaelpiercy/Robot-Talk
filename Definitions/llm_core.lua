-- LLM Core for Caleb's AI Assistant
-- Solar2D compatible implementation

local LLMCore = {}

-- Conversation memory
local conversationHistory = {}
local contextMemory = {}
local userPreferences = {}

-- Response templates and patterns
local responsePatterns = {
    greeting = {
        patterns = {"hello", "hi", "hey", "good morning", "good afternoon", "good evening"},
        responses = {
            "Hello! I'm Caleb's AI assistant. How can I help you today?",
            "Hi there! I'm here to assist you with any questions.",
            "Greetings! I'm ready to help with whatever you need.",
            "Hello! What would you like to know?"
        }
    },
    farewell = {
        patterns = {"bye", "goodbye", "see you", "later", "exit", "quit"},
        responses = {
            "Goodbye! It was nice talking with you.",
            "See you later! Feel free to come back anytime.",
            "Take care! I'll be here when you need me.",
            "Bye! Have a great day!"
        }
    },
    question = {
        patterns = {"what", "how", "why", "when", "where", "who", "which"},
        responses = {
            "That's an interesting question. Let me think about that...",
            "I'd be happy to help you with that.",
            "That's a great question. Here's what I know...",
            "Let me provide you with some information on that."
        }
    },
    gratitude = {
        patterns = {"thank", "thanks", "appreciate"},
        responses = {
            "You're welcome! I'm glad I could help.",
            "My pleasure! Is there anything else you'd like to know?",
            "You're very welcome! Feel free to ask more questions.",
            "Anytime! I'm here to help."
        }
    },
    weather = {
        patterns = {"weather", "temperature", "rain", "sunny", "cold", "hot"},
        responses = {
            "I can't check real-time weather, but I can help you find weather apps or websites!",
            "For current weather information, I'd recommend checking a weather service.",
            "Weather conditions change frequently. You might want to check a local weather service."
        }
    },
    time = {
        patterns = {"time", "clock", "hour", "minute"},
        responses = {
            "I can't tell you the exact time, but you can check your device's clock!",
            "For the current time, please look at your device's clock or calendar.",
            "Time is relative, but your device should show you the current time."
        }
    },
    math = {
        patterns = {"calculate", "math", "add", "subtract", "multiply", "divide", "sum", "plus", "minus"},
        responses = {
            "I can help with basic math concepts, but for calculations you might want to use a calculator.",
            "Math is fascinating! What specific calculation are you thinking about?",
            "I can discuss mathematical concepts, but for actual calculations, a calculator would be more precise."
        }
    }
}

-- Analyze input
function LLMCore:analyzeInput(input)
    if not input then
        return {
            intent = "general",
            confidence = 0,
            keywords = {},
            sentiment = "neutral"
        }
    end
    
    local inputLower = string.lower(input)
    local analysis = {
        intent = "general",
        confidence = 0,
        keywords = {},
        sentiment = "neutral"
    }
    
    -- Extract keywords
    for word in inputLower:gmatch("%w+") do
        table.insert(analysis.keywords, word)
    end
    
    -- Determine intent based on patterns
    for intent, data in pairs(responsePatterns) do
        for _, pattern in ipairs(data.patterns) do
            if inputLower:find(pattern) then
                analysis.intent = intent
                analysis.confidence = analysis.confidence + 0.3
                break
            end
        end
    end
    
    -- Basic sentiment analysis
    local positiveWords = {"good", "great", "awesome", "amazing", "love", "like", "happy", "excellent"}
    local negativeWords = {"bad", "terrible", "hate", "awful", "sad", "angry", "dislike", "horrible"}
    
    for _, word in ipairs(positiveWords) do
        if inputLower:find(word) then
            analysis.sentiment = "positive"
            break
        end
    end
    
    for _, word in ipairs(negativeWords) do
        if inputLower:find(word) then
            analysis.sentiment = "negative"
            break
        end
    end
    
    return analysis
end

-- Generate response
function LLMCore:generateResponse(input, analysis)
    local response = ""
    
    -- Get context from conversation history
    local context = self:getContext()
    
    -- Try to use knowledge base for intelligent responses
    local success, KnowledgeBase = pcall(require, "Definitions.knowledge_base")
    if success then
        local knowledgeResponse = KnowledgeBase:generateIntelligentResponse(input)
        if knowledgeResponse and knowledgeResponse ~= "" then
            response = knowledgeResponse
        end
    end
    
    -- If no knowledge base response, use pattern matching
    if response == "" then
        if responsePatterns[analysis.intent] then
            local responses = responsePatterns[analysis.intent].responses
            response = responses[math.random(1, #responses)]
        else
            -- Default responses for general conversation
            local generalResponses = {
                "That's interesting! Tell me more about that.",
                "I see what you mean. What are your thoughts on that?",
                "That's a good point. How do you feel about it?",
                "I understand. Is there anything specific you'd like to discuss?",
                "That's fascinating! I'd love to hear more.",
                "I see. What would you like to explore further?"
            }
            response = generalResponses[math.random(1, #generalResponses)]
        end
    end
    
    -- Add contextual information if available
    if context and context.lastTopic then
        response = response .. " By the way, you mentioned " .. context.lastTopic .. " earlier."
    end
    
    -- Add sentiment-appropriate response
    if analysis.sentiment == "positive" then
        response = response .. " I'm glad you're feeling positive about this!"
    elseif analysis.sentiment == "negative" then
        response = response .. " I understand this might be challenging. Is there anything I can do to help?"
    end
    
    return response
end

-- Get context
function LLMCore:getContext()
    if #conversationHistory > 0 then
        return {
            lastTopic = conversationHistory[#conversationHistory].keywords[1],
            conversationLength = #conversationHistory,
            userMood = conversationHistory[#conversationHistory].sentiment
        }
    end
    return nil
end

-- Process input
function LLMCore:processInput(userInput)
    if not userInput then
        return "I didn't catch that. Could you please repeat?"
    end
    
    -- Analyze the input
    local analysis = self:analyzeInput(userInput)
    
    -- Store in conversation history
    table.insert(conversationHistory, {
        input = userInput,
        analysis = analysis,
        timestamp = os.time()
    })
    
    -- Generate response
    local response = self:generateResponse(userInput, analysis)
    
    -- Store response in history
    table.insert(conversationHistory, {
        input = response,
        analysis = {intent = "response", confidence = 1, keywords = {}, sentiment = "neutral"},
        timestamp = os.time(),
        isResponse = true
    })
    
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
end

-- Get memory stats
function LLMCore:getMemoryStats()
    return {
        conversationCount = #conversationHistory,
        memorySize = #conversationHistory * 100, -- Rough estimate
        lastInteraction = conversationHistory[#conversationHistory] and conversationHistory[#conversationHistory].timestamp or 0
    }
end

return LLMCore