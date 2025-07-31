# Debug Mode Guide - Caleb's AI Assistant

## 🔧 **DEBUG MODE IMPLEMENTATION**

The application now includes comprehensive debug mode functionality to help identify and resolve issues with conversation processing and UI interactions.

## 📋 **DEBUG FEATURES IMPLEMENTED**

### **1. Main Application Debug (`main.lua`)**
```lua
---@type boolean Debug mode flag for console output
local DEBUG_MODE = true

---Debug print function
---@param message string The debug message to print
local function debugPrint(message)
    if DEBUG_MODE then
        print("[DEBUG] " .. message)
    end
end
```

**Debug Output Examples:**
```
[DEBUG] ✓ Loaded module: knowledgeBase
[DEBUG] ✓ Loaded module: llmCore
[DEBUG] ✓ Loaded module: aiRobot
[DEBUG] ✓ Loaded module: uiManager
[DEBUG] Injecting dependencies into UI Manager...
[DEBUG] ✓ LLM Core injected into UI Manager
[DEBUG] ✓ Knowledge Base injected into UI Manager
[DEBUG] ✓ AI Robot injected into UI Manager
[DEBUG] ✓ Debug mode enabled in UI Manager
```

### **2. UI Manager Debug (`Framework/ui_manager.lua`)**
```lua
---Debug print function
---@param message string The debug message to print
local function debugPrint(message)
    print("[UI DEBUG] " .. message)
end
```

**Debug Output Examples:**
```
[UI DEBUG] Initializing UI Manager...
[UI DEBUG] Chat container created at position: 320, 240
[UI DEBUG] ✓ UI Manager initialized successfully!
[UI DEBUG] Send button pressed
[UI DEBUG] Processing user input: Hello
[UI DEBUG] LLM Core available, processing with AI...
[UI DEBUG] ✓ Robot processed input successfully
[UI DEBUG] AI Response: Hello! How can I help you today?
[UI DEBUG] Adding chat bubble: AI - Hello! How can I help you today?
[UI DEBUG] Bubble positioned at: 150, 270
[UI DEBUG] Status updated: AI Assistant - 1 messages
[UI DEBUG] Memory stats updated: 1 conversations
```

### **3. LLM Core Debug (`Definitions/llm_core.lua`)**
```lua
---Debug print function
---@param message string The debug message to print
local function debugPrint(message)
    if debugMode then
        print("[LLM DEBUG] " .. message)
    end
end
```

**Debug Output Examples:**
```
[LLM DEBUG] Processing input: What is artificial intelligence?
[LLM DEBUG] Analyzing input: What is artificial intelligence?
[LLM DEBUG] Extracted keywords: what, artificial, intelligence
[LLM DEBUG] Detected intent: question
[LLM DEBUG] Detected sentiment: neutral
[LLM DEBUG] Analysis complete - Intent: question, Sentiment: neutral, Confidence: 0.7
[LLM DEBUG] Generating response for intent: question
[LLM DEBUG] Knowledge Base available, attempting intelligent response
[LLM DEBUG] Knowledge-based response generated: Artificial Intelligence (AI) is technology that enables machines to simulate human intelligence.
[LLM DEBUG] Final response: Artificial Intelligence (AI) is technology that enables machines to simulate human intelligence.
[LLM DEBUG] Conversation stored - Total conversations: 1, History size: 1
```

## 🎯 **CONVERSATION TRACKING**

### **Conversation Log Output**
```
[UI DEBUG] === CONVERSATION LOG ===
[UI DEBUG] 1. User: Hello
[UI DEBUG] 2. AI: Hello! How can I help you today?
[UI DEBUG] 3. User: What is programming?
[UI DEBUG] 4. AI: Programming is the process of creating instructions for computers to follow.
[UI DEBUG] ========================
```

### **Memory Statistics Tracking**
```
[LLM DEBUG] Memory stats - Conversations: 2, History: 2
[UI DEBUG] Memory stats updated: 2 conversations
```

## 🔍 **ISSUE DIAGNOSIS FEATURES**

### **1. Dependency Injection Tracking**
- **Module Loading**: Tracks successful/failed module loads
- **Dependency Injection**: Confirms proper object relationships
- **Instance Creation**: Validates object instantiation

### **2. Input Processing Tracking**
- **Input Validation**: Shows validation results
- **Text Processing**: Tracks sanitization and processing
- **Intent Detection**: Shows detected intent and confidence
- **Sentiment Analysis**: Displays sentiment detection results

### **3. Response Generation Tracking**
- **Knowledge Base**: Shows if KB is available and used
- **Response Selection**: Tracks which response pattern is used
- **Fallback Handling**: Shows when fallback responses are used

### **4. UI Interaction Tracking**
- **Button Presses**: Tracks user interactions
- **Chat Bubble Creation**: Shows bubble positioning
- **Status Updates**: Tracks UI state changes
- **Memory Updates**: Shows conversation statistics

## 🛠️ **DEBUG MODE CONTROLS**

### **Enable/Disable Debug Mode**
```lua
-- In main.lua
local DEBUG_MODE = true  -- Set to false to disable

-- In UI Manager
self.state.debugMode = true  -- Set to false to disable

-- In LLM Core
llm:setDebugMode(true)  -- Set to false to disable
```

### **Debug Output Categories**
1. **[DEBUG]** - Main application initialization and dependency management
2. **[UI DEBUG]** - User interface interactions and chat bubble management
3. **[LLM DEBUG]** - Language model processing and response generation

## 📊 **COMMON DEBUG SCENARIOS**

### **Scenario 1: No Response from Robot**
**Debug Output to Check:**
```
[UI DEBUG] Send button pressed
[UI DEBUG] Processing user input: [your input]
[UI DEBUG] LLM Core available, processing with AI...
[LLM DEBUG] Processing input: [your input]
[LLM DEBUG] AI Response: [response]
[UI DEBUG] Adding chat bubble: AI - [response]
```

**If Missing:**
- Check if "LLM Core available" appears
- Verify "AI Response" is generated
- Confirm "Adding chat bubble" executes

### **Scenario 2: Chat Bubbles Not Visible**
**Debug Output to Check:**
```
[UI DEBUG] Chat container created at position: 320, 240
[UI DEBUG] Adding chat bubble: User - [input]
[UI DEBUG] Bubble positioned at: [x], [y]
```

**If Missing:**
- Verify chat container position is correct
- Check if bubble positioning is within visible area
- Confirm messages group exists

### **Scenario 3: No AI Processing**
**Debug Output to Check:**
```
[LLM DEBUG] Processing input: [input]
[LLM DEBUG] Analyzing input: [input]
[LLM DEBUG] Extracted keywords: [keywords]
[LLM DEBUG] Detected intent: [intent]
[LLM DEBUG] Generating response for intent: [intent]
[LLM DEBUG] Final response: [response]
```

**If Missing:**
- Check if LLM Core is properly injected
- Verify input validation passes
- Confirm response generation completes

## 🚀 **USING DEBUG MODE**

### **1. Enable Debug Mode**
Set `DEBUG_MODE = true` in `main.lua` and run the application.

### **2. Monitor Console Output**
Watch for debug messages that indicate:
- ✅ Successful operations
- ⚠️ Warnings and fallbacks
- ❌ Errors and failures

### **3. Test Conversation Flow**
1. Type a message and press Send
2. Check console for processing steps
3. Verify chat bubble creation
4. Confirm AI response generation

### **4. Identify Issues**
- **No Response**: Check LLM Core injection and processing
- **No Bubbles**: Verify chat container positioning
- **No AI**: Confirm knowledge base availability
- **Errors**: Look for specific error messages

## 📈 **DEBUG OUTPUT EXAMPLES**

### **Successful Conversation Flow:**
```
[DEBUG] ✓ Loaded module: knowledgeBase
[DEBUG] ✓ Loaded module: llmCore
[DEBUG] ✓ Loaded module: uiManager
[DEBUG] ✓ LLM Core injected into UI Manager
[DEBUG] ✓ Knowledge Base injected into UI Manager
[UI DEBUG] Send button pressed
[UI DEBUG] Processing user input: Hello
[UI DEBUG] LLM Core available, processing with AI...
[LLM DEBUG] Processing input: Hello
[LLM DEBUG] Analyzing input: Hello
[LLM DEBUG] Extracted keywords: hello
[LLM DEBUG] Detected intent: greeting
[LLM DEBUG] Detected sentiment: neutral
[LLM DEBUG] Generating response for intent: greeting
[LLM DEBUG] Knowledge-based response generated: Hello! How can I help you today?
[LLM DEBUG] Final response: Hello! How can I help you today?
[UI DEBUG] AI Response: Hello! How can I help you today?
[UI DEBUG] Adding chat bubble: AI - Hello! How can I help you today?
[UI DEBUG] Bubble positioned at: 150, 270
[UI DEBUG] Status updated: AI Assistant - 1 messages
```

### **Error Detection:**
```
[UI DEBUG] Send button pressed
[UI DEBUG] Processing user input: [input]
[UI DEBUG] LLM Core not available, using fallback response
[UI DEBUG] Adding chat bubble: AI - That's an interesting question!
[UI DEBUG] Status updated: AI Assistant - Demo Mode
```

## 🎯 **RESULT: COMPREHENSIVE DEBUGGING**

The application now provides:
- ✅ **Complete conversation tracking** with detailed logs
- ✅ **Dependency injection monitoring** for proper object relationships
- ✅ **Input processing validation** with step-by-step tracking
- ✅ **UI interaction debugging** for chat bubble visibility
- ✅ **Error detection and reporting** for quick issue identification
- ✅ **Memory and statistics tracking** for conversation management

With debug mode enabled, you can now easily identify and resolve any issues with the conversation flow, chat bubble visibility, or AI response generation!