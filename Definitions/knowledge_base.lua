local KnowledgeBase = {}

-- Knowledge categories
local knowledge = {
    general = {
        greetings = {
            "Hello! How can I assist you today?",
            "Hi there! I'm here to help with any questions.",
            "Greetings! What would you like to know?"
        },
        farewells = {
            "Goodbye! Have a great day!",
            "See you later! Feel free to return anytime.",
            "Take care! I'll be here when you need me."
        },
        gratitude = {
            "You're welcome! I'm glad I could help.",
            "My pleasure! Is there anything else you'd like to know?",
            "Anytime! I'm here to assist you."
        }
    },
    
    technology = {
        programming = {
            "Programming is the art of telling computers what to do. Popular languages include Python, JavaScript, and Lua.",
            "Coding involves writing instructions for computers to follow. It's like giving them a recipe to follow.",
            "Software development is creating applications and systems that solve problems or provide entertainment."
        },
        ai = {
            "Artificial Intelligence is technology that enables machines to learn and make decisions.",
            "AI includes machine learning, natural language processing, and computer vision.",
            "AI assistants like me use language models to understand and respond to human input."
        },
        internet = {
            "The internet is a global network connecting computers and devices worldwide.",
            "Web browsers like Chrome and Safari help you access websites and online services.",
            "The World Wide Web is a collection of interconnected documents and resources."
        }
    },
    
    science = {
        physics = {
            "Physics studies matter, energy, and their interactions. It explains how the universe works.",
            "Gravity is a force that pulls objects toward each other. It keeps us on Earth.",
            "Light travels at about 186,000 miles per second - the fastest known speed in the universe."
        },
        chemistry = {
            "Chemistry is the study of matter and how substances change and interact.",
            "Atoms are the building blocks of all matter. They combine to form molecules.",
            "Chemical reactions occur when substances combine or break apart to form new materials."
        },
        biology = {
            "Biology is the study of living organisms and their interactions with the environment.",
            "Cells are the basic units of life. All living things are made of cells.",
            "DNA contains the genetic instructions that determine an organism's characteristics."
        }
    },
    
    math = {
        arithmetic = {
            "Addition combines numbers to find their sum. Subtraction finds the difference between numbers.",
            "Multiplication is repeated addition. Division shares numbers into equal groups.",
            "Fractions represent parts of a whole. Decimals are another way to write fractions."
        },
        geometry = {
            "Geometry studies shapes, sizes, and spatial relationships.",
            "A circle is perfectly round. A square has four equal sides and four right angles.",
            "Area measures how much space a shape covers. Perimeter is the distance around a shape."
        }
    },
    
    history = {
        ancient = {
            "Ancient civilizations like Egypt, Greece, and Rome built impressive structures and developed advanced cultures.",
            "The pyramids of Egypt were built as tombs for pharaohs over 4,000 years ago.",
            "Ancient Greece is known for democracy, philosophy, and the Olympic Games."
        },
        modern = {
            "The Industrial Revolution began in the 18th century and changed how goods were manufactured.",
            "World War II ended in 1945 and led to major changes in world politics and technology.",
            "The internet was developed in the late 20th century and revolutionized communication."
        }
    },
    
    entertainment = {
        games = {
            "Video games are interactive entertainment that can be played on computers, consoles, or mobile devices.",
            "Board games have been played for thousands of years and bring people together.",
            "Puzzles challenge your mind and can be both fun and educational."
        },
        movies = {
            "Movies tell stories through moving images and sound. They can entertain, educate, or inspire.",
            "Animation brings drawings or computer graphics to life to tell stories.",
            "Documentaries present real events and information in an engaging way."
        },
        music = {
            "Music is organized sound that can express emotions and tell stories.",
            "Different instruments create different sounds and moods in music.",
            "Genres like rock, jazz, and classical each have their own unique characteristics."
        }
    }
}

-- Response patterns for different types of questions
local responsePatterns = {
    what = {
        "That's a great question! Let me explain...",
        "I'd be happy to tell you about that.",
        "Here's what I know about that topic...",
        "That's an interesting topic. Here's some information..."
    },
    how = {
        "Let me walk you through how that works...",
        "Here's how you can do that...",
        "The process involves several steps...",
        "Let me explain the method..."
    },
    why = {
        "The reason for that is...",
        "This happens because...",
        "The explanation is...",
        "Here's why that occurs..."
    },
    when = {
        "That typically happens when...",
        "The timing depends on...",
        "You can expect that to occur...",
        "The best time for that would be..."
    },
    where = {
        "You can find that at...",
        "The location is typically...",
        "That's usually located...",
        "You'll want to look for..."
    }
}

function KnowledgeBase:getResponse(category, topic)
    if knowledge[category] and knowledge[category][topic] then
        local responses = knowledge[category][topic]
        return responses[math.random(1, #responses)]
    end
    return nil
end

function KnowledgeBase:findRelevantInfo(input)
    local inputLower = string.lower(input)
    local relevantInfo = {}
    
    -- Search through all categories
    for category, topics in pairs(knowledge) do
        for topic, responses in pairs(topics) do
            if inputLower:find(topic) then
                table.insert(relevantInfo, {
                    category = category,
                    topic = topic,
                    response = responses[math.random(1, #responses)]
                })
            end
        end
    end
    
    return relevantInfo
end

function KnowledgeBase:getResponsePattern(questionType)
    if responsePatterns[questionType] then
        return responsePatterns[questionType][math.random(1, #responsePatterns[questionType])]
    end
    return "Let me help you with that."
end

function KnowledgeBase:analyzeQuestion(input)
    local inputLower = string.lower(input)
    local questionType = "general"
    
    -- Determine question type
    if inputLower:find("^what") then
        questionType = "what"
    elseif inputLower:find("^how") then
        questionType = "how"
    elseif inputLower:find("^why") then
        questionType = "why"
    elseif inputLower:find("^when") then
        questionType = "when"
    elseif inputLower:find("^where") then
        questionType = "where"
    end
    
    -- Find relevant information
    local relevantInfo = self:findRelevantInfo(input)
    
    return {
        questionType = questionType,
        relevantInfo = relevantInfo,
        hasRelevantInfo = #relevantInfo > 0
    }
end

function KnowledgeBase:generateIntelligentResponse(input)
    local analysis = self:analyzeQuestion(input)
    local response = ""
    
    if analysis.hasRelevantInfo then
        -- Use relevant information from knowledge base
        local info = analysis.relevantInfo[1]
        response = self:getResponsePattern(analysis.questionType) .. " " .. info.response
    else
        -- Generate a general response
        response = "That's an interesting question. While I don't have specific information about that, I'd be happy to help you find resources or discuss related topics."
    end
    
    return response
end

function KnowledgeBase:getRandomFact()
    local categories = {"technology", "science", "math", "history", "entertainment"}
    local category = categories[math.random(1, #categories)]
    
    if knowledge[category] then
        local topics = {}
        for topic, _ in pairs(knowledge[category]) do
            table.insert(topics, topic)
        end
        
        if #topics > 0 then
            local topic = topics[math.random(1, #topics)]
            return self:getResponse(category, topic)
        end
    end
    
    return "Did you know that learning new things helps keep your brain active and healthy?"
end

return KnowledgeBase