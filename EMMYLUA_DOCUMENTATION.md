# EmmyLua Documentation - Caleb's AI Assistant

## 📋 **OVERVIEW**

This document provides comprehensive EmmyLua type annotations and documentation for the entire Caleb's AI Assistant application. All modules now include:

- **Type hints** for all variables and parameters
- **Return value documentation** for all functions
- **Class definitions** with field descriptions
- **Parameter validation** with proper error handling
- **Comprehensive documentation** for maintainability

## 🏗️ **CORE TYPE DEFINITIONS**

### **Main Application Types**

```lua
---@class AppState
---@field modules table<string, any> Core modules loaded in dependency order
---@field personalityButtons table<number, DisplayObject> Array of personality selector buttons
---@field currentPersonalityIndex number Current selected personality index
---@field isInitialized boolean Whether the application has been initialized
---@field isShuttingDown boolean Whether the application is shutting down
```

### **UI Manager Types**

```lua
---@class UIManager
---@field state UIState The instance-specific state

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

---@class BubbleStyle
---@field backgroundColor number[] Background color RGBA values
---@field textColor number[] Text color RGBA values
---@field cornerRadius number Corner radius for rounded rectangle
---@field maxWidth number Maximum width of the bubble
```

### **AI Robot Types**

```lua
---@class AIRobot
---@field sprite DisplayObject|nil The robot sprite display object
---@field personalityIndicator TextObject|nil The personality indicator text
---@field energyBar DisplayObject|nil The energy bar display object
---@field moodIndicator TextObject|nil The mood indicator text
---@field currentPersonality string The current personality setting
---@field currentMood string The current mood state
---@field energyLevel number The current energy level (0-100)
---@field isAnimating boolean Whether an animation is currently playing

---@class RobotState
---@field sprite DisplayObject|nil The robot sprite display object
---@field personalityIndicator TextObject|nil The personality indicator text
---@field energyBar DisplayObject|nil The energy bar display object
---@field moodIndicator TextObject|nil The mood indicator text
---@field currentPersonality string The current personality setting
---@field currentMood string The current mood state
---@field energyLevel number The current energy level (0-100)
---@field isAnimating boolean Whether an animation is currently playing

---@class AnimationConfig
---@field duration number Animation duration in milliseconds
---@field alpha? number[] Alpha values for animation
---@field scale? number[] Scale values for animation
---@field rotation? number[] Rotation values for animation

---@class PersonalityResponses
---@field greeting string Greeting response
---@field thinking string Thinking response
---@field excited string Excited response
---@field sad string Sad response
```

### **LLM Core Types**

```lua
---@class LLMCore
---@field conversationHistory ConversationEntry[] Array of conversation history entries
---@field contextMemory table<string, ContextEntry> Context memory storage
---@field userPreferences table<string, PreferenceEntry> User preference storage
---@field conversationCount number Total number of conversations processed

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
```

### **Knowledge Base Types**

```lua
---@class KnowledgeBase
---@field knowledge table<string, table<string, string[]>> The structured knowledge repository
---@field responsePatterns table<string, string[]> Response patterns for different question types

---@class KnowledgeCategory
---@field [string] string[] Array of responses for each topic

---@class KnowledgeRepository
---@field general KnowledgeCategory General knowledge responses
---@field technology KnowledgeCategory Technology-related responses
---@field science KnowledgeCategory Science-related responses
---@field math KnowledgeCategory Mathematics-related responses
---@field history KnowledgeCategory History-related responses
---@field entertainment KnowledgeCategory Entertainment-related responses
```

## 🔧 **FUNCTION DOCUMENTATION PATTERNS**

### **Constructor Functions**

```lua
---Constructor with proper instance isolation
---@return UIManager The new UI manager instance
function UIManager:new()
```

### **Initialization Functions**

```lua
---Initialize the UI with proper scope
---@return boolean success Whether the UI manager was initialized successfully
function UIManager:init()
```

### **Core Processing Functions**

```lua
---Process user input with validation
---@param text string The user input text to process
function UIManager:processUserInput(text)

---Analyze input for intent and sentiment
---@param input string|nil The input text to analyze
---@return InputAnalysis The analysis result
function LLMCore:analyzeInput(input)
```

### **UI Component Functions**

```lua
---Create chat container with instance scope
---@return boolean success Whether the chat container was created successfully
function UIManager:createChatContainer()

---Add chat bubble with instance scope
---@param text string The text to display in the chat bubble
---@param isUser boolean Whether this is a user message (true) or AI message (false)
---@return DisplayObject|nil The created chat bubble group or nil if failed
function UIManager:addChatBubble(text, isUser)
```

### **Knowledge Base Functions**

```lua
---Get specific knowledge response
---@param category string The knowledge category
---@param topic string The knowledge topic
---@return string|nil The knowledge response or nil if not found
function KnowledgeBase:getResponse(category, topic)

---Generate intelligent response
---@param keywords string[] The keywords to search for
---@return string The generated response
function KnowledgeBase:generateIntelligentResponse(keywords)
```

### **Safety & Utility Functions**

```lua
---Safe module loading with dependency tracking
---@param modulePath string The path to the module to load
---@param dependencyName? string The name to store the module under in app.modules
---@return any|nil The loaded module or nil if failed
local function safeRequire(modulePath, dependencyName)

---Safe function call wrapper with scope validation
---@param func function|nil The function to call
---@param context table|nil The context object (self) for the function
---@param ... any Additional arguments to pass to the function
---@return boolean success Whether the function call succeeded
---@return any result The result of the function call or error message
local function safeCall(func, context, ...)

---Input validation function
---@param text string|nil The text to validate
---@return boolean valid Whether the input is valid
---@return string|string sanitized The sanitized text or error message
local function validateInput(text)
```

## 📊 **TYPE ANNOTATION BENEFITS**

### **1. Enhanced IDE Support**
- **IntelliSense** provides autocomplete for all functions and properties
- **Type checking** catches errors at development time
- **Parameter hints** show expected types and descriptions
- **Go to definition** works for all custom types

### **2. Improved Code Quality**
- **Type safety** prevents runtime type errors
- **Documentation** is embedded in the code
- **Maintainability** is enhanced with clear type definitions
- **Refactoring** is safer with type-aware tools

### **3. Better Debugging**
- **Type hints** help identify parameter issues
- **Return types** clarify function behavior
- **Error messages** are more specific with type information
- **IDE warnings** catch potential issues early

### **4. Team Collaboration**
- **Self-documenting code** with embedded type information
- **Clear interfaces** between modules
- **Consistent patterns** across the codebase
- **Reduced onboarding time** for new developers

## 🎯 **IMPLEMENTATION PATTERNS**

### **Module Structure**
```lua
---@meta
---@diagnostic disable: undefined-global

-- Module description
-- Expert-level implementation with comprehensive error handling

---@class ModuleName
---@field property type Description

local ModuleName = {}

-- ============================================================================
-- SECTION NAME
-- ============================================================================

---@class TypeName
---@field field type Description

---@type TypeName Description
local variable = {}

-- ============================================================================
-- FUNCTIONALITY
-- ============================================================================

---Function description
---@param param type Description
---@return type Description
function ModuleName:functionName(param)
    -- Implementation
end
```

### **Error Handling Pattern**
```lua
---Safe operation with error handling
---@param input type The input to process
---@return boolean success Whether the operation succeeded
---@return any result The result or error message
local function safeOperation(input)
    if not input then
        print("Warning: No input provided")
        return false, "No input provided"
    end
    
    local success, result = pcall(function()
        -- Actual operation
        return result
    end)
    
    if not success then
        print("Warning: Operation failed:", result)
        return false, result
    end
    
    return true, result
end
```

### **Type Validation Pattern**
```lua
---Validate and process input
---@param input any The input to validate
---@return boolean valid Whether the input is valid
---@return any processed The processed input or error message
local function validateAndProcess(input)
    if not input then
        return false, "No input provided"
    end
    
    if type(input) ~= "string" then
        return false, "Invalid input type"
    end
    
    if string.len(input) == 0 then
        return false, "Empty input"
    end
    
    -- Process valid input
    return true, input
end
```

## 🚀 **RESULT: PROFESSIONAL-GRADE CODEBASE**

The application now features:

✅ **Complete type safety** with EmmyLua annotations  
✅ **Self-documenting code** with embedded documentation  
✅ **IDE-friendly structure** with proper type hints  
✅ **Maintainable architecture** with clear interfaces  
✅ **Professional standards** with comprehensive error handling  
✅ **Team-ready codebase** with consistent patterns  

Every function, class, and variable is now properly documented with EmmyLua annotations, making the codebase professional-grade and maintainable for long-term development.