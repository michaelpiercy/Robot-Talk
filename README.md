# Caleb's AI Assistant - Enhanced LLM System

A sophisticated AI assistant built with Lua and Solar 2D, featuring natural language processing, conversation memory, and intelligent response generation.

## Features

### 🤖 **AI Core System**
- **Natural Language Processing**: Analyzes user input for intent, sentiment, and keywords
- **Conversation Memory**: Remembers previous interactions and maintains context
- **Intelligent Response Generation**: Uses knowledge base and context to provide relevant answers
- **Sentiment Analysis**: Detects positive, negative, and neutral emotions in user input

### 🧠 **Knowledge Base**
- **Multi-Domain Knowledge**: Covers technology, science, math, history, and entertainment
- **Contextual Responses**: Provides relevant information based on user questions
- **Question Analysis**: Understands different types of questions (what, how, why, when, where)
- **Random Facts**: Generates interesting facts to engage users

### 🎨 **Enhanced UI**
- **Modern Chat Interface**: Clean, responsive chat bubbles for user and AI messages
- **Real-time Input**: Text input field with send button and keyboard support
- **Memory Management**: Visual display of conversation count and memory usage
- **Personality Selection**: Choose between helpful, friendly, and professional AI personalities

### 🤖 **Animated Robot Character**
- **Dynamic Animations**: Idle, thinking, excited, and sad animations
- **Visual Feedback**: Robot responds to user sentiment with appropriate animations
- **Energy System**: Visual energy bar that changes based on interaction frequency
- **Mood Indicators**: Emoji-based mood display that reflects conversation sentiment

### 📊 **System Features**
- **Memory Statistics**: Track conversation count and memory usage
- **Context Awareness**: AI remembers previous topics and references them
- **Personality Modes**: Three distinct AI personalities with different response styles
- **Clean Memory**: Option to clear conversation history

## Architecture

### Core Modules

1. **`Definitions/llm_core.lua`** - Main LLM engine with NLP and response generation
2. **`Definitions/knowledge_base.lua`** - Knowledge repository with multi-domain information
3. **`Definitions/ai_robot.lua`** - Animated robot character with personality and animations
4. **`Framework/ui_manager.lua`** - Modern UI system with chat interface and controls

### Key Components

- **Natural Language Processing**: Pattern matching and keyword extraction
- **Conversation Memory**: Persistent storage of user interactions
- **Knowledge Integration**: Intelligent response generation using knowledge base
- **Visual Feedback**: Robot animations and UI updates based on interaction

## Usage

### Starting the Application
1. Run the Solar 2D application
2. The AI assistant will greet you with a welcome message
3. Type your questions or messages in the input field
4. Press Enter or tap the Send button to get a response

### Personality Selection
- **Helpful**: Focuses on providing assistance and guidance
- **Friendly**: Conversational and engaging responses
- **Professional**: Formal and structured communication

### Features
- **Ask Questions**: The AI can answer questions about various topics
- **Conversation Memory**: The AI remembers previous interactions
- **Visual Feedback**: Watch the robot animate based on your messages
- **Memory Management**: Clear conversation history when needed

## Technical Details

### Dependencies
- Solar 2D Framework
- Lua programming language
- Native UI components (text fields, buttons, scroll views)

### File Structure
```
├── main.lua                 # Main application entry point
├── config.lua              # Application configuration
├── Definitions/
│   ├── llm_core.lua       # Core LLM functionality
│   ├── knowledge_base.lua  # Knowledge repository
│   ├── ai_robot.lua       # Robot character system
│   └── responses.lua      # Legacy response system
├── Framework/
│   ├── ui_manager.lua     # UI management system
│   └── functions.lua      # Legacy framework functions
└── robot.png              # Robot character sprite
```

### Key Algorithms

1. **Input Analysis**: Pattern matching for intent detection and sentiment analysis
2. **Response Generation**: Context-aware response selection with knowledge base integration
3. **Memory Management**: Conversation history tracking and context preservation
4. **Animation System**: State-based animation triggering for visual feedback

## Future Enhancements

- **Machine Learning Integration**: Implement basic ML for improved response quality
- **Voice Recognition**: Add speech-to-text capabilities
- **Multi-language Support**: Extend to support multiple languages
- **Advanced NLP**: Implement more sophisticated natural language understanding
- **Cloud Integration**: Connect to external APIs for real-time information
- **Custom Knowledge**: Allow users to add their own knowledge to the system

## Development

This system demonstrates advanced Lua programming concepts including:
- Object-oriented programming with metatables
- Event-driven architecture
- State management
- UI/UX design principles
- Animation and visual feedback systems

The codebase is modular and extensible, making it easy to add new features and capabilities.