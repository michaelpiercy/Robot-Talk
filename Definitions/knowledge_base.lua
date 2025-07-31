-- Knowledge Base Module for Caleb's AI Assistant
-- Expert-level Solar2D implementation with comprehensive error handling

local KnowledgeBase = {}

-- Structured knowledge repository
local knowledge = {
    general = {
        greetings = {
            "Hello! How can I help you today?",
            "Hi there! I'm here to assist you.",
            "Greetings! What would you like to know?"
        },
        farewells = {
            "Goodbye! Have a great day!",
            "See you later! Feel free to return anytime.",
            "Take care! I'm here when you need me."
        }
    },
    technology = {
        programming = {
            "Programming is the process of creating instructions for computers to follow.",
            "Popular programming languages include Python, JavaScript, Java, and C++.",
            "Learning to code opens up many career opportunities in technology.",
            "Programming involves problem-solving, logic, and creativity."
        },
        artificial_intelligence = {
            "Artificial Intelligence (AI) is technology that enables machines to simulate human intelligence.",
            "AI includes machine learning, natural language processing, and computer vision.",
            "AI is used in virtual assistants, recommendation systems, and autonomous vehicles.",
            "The field of AI is rapidly advancing and transforming many industries."
        },
        internet = {
            "The Internet is a global network of connected computers and devices.",
            "The World Wide Web (WWW) is a system of interlinked hypertext documents.",
            "The Internet enables communication, information sharing, and online services.",
            "Internet protocols like HTTP and TCP/IP make global communication possible."
        },
        computers = {
            "Computers are electronic devices that process data according to instructions.",
            "A computer consists of hardware (physical components) and software (programs).",
            "Modern computers can perform billions of calculations per second.",
            "Computers are used in almost every aspect of modern life."
        }
    },
    science = {
        physics = {
            "Physics is the study of matter, energy, and their interactions.",
            "Key concepts include gravity, electromagnetism, and quantum mechanics.",
            "Physics explains how the universe works at both microscopic and cosmic scales.",
            "Understanding physics helps us develop new technologies and innovations."
        },
        chemistry = {
            "Chemistry is the study of matter and the changes it undergoes.",
            "Atoms are the building blocks of all matter in the universe.",
            "Chemical reactions involve the rearrangement of atoms and molecules.",
            "Chemistry is essential for medicine, materials science, and environmental studies."
        },
        biology = {
            "Biology is the study of living organisms and their interactions.",
            "Cells are the basic units of life in all living things.",
            "Evolution explains how species change over time through natural selection.",
            "Biology helps us understand health, disease, and environmental systems."
        },
        astronomy = {
            "Astronomy is the study of celestial objects and phenomena.",
            "Our solar system includes the Sun, planets, moons, and other objects.",
            "The universe contains billions of galaxies, each with billions of stars.",
            "Astronomy helps us understand our place in the cosmos."
        }
    },
    math = {
        arithmetic = {
            "Arithmetic deals with basic operations: addition, subtraction, multiplication, and division.",
            "Numbers can be whole numbers, fractions, decimals, or negative numbers.",
            "Understanding arithmetic is fundamental to all other areas of mathematics.",
            "Mental math skills help with everyday calculations and problem-solving."
        },
        algebra = {
            "Algebra uses letters and symbols to represent numbers and relationships.",
            "Equations are mathematical statements that show equality between expressions.",
            "Solving equations involves finding the value of unknown variables.",
            "Algebra is essential for advanced mathematics and many real-world applications."
        },
        geometry = {
            "Geometry studies shapes, sizes, positions, and dimensions of objects.",
            "Basic shapes include circles, triangles, squares, and rectangles.",
            "Area measures the space inside a shape, while perimeter measures the distance around it.",
            "Geometry is used in architecture, engineering, and design."
        },
        statistics = {
            "Statistics involves collecting, analyzing, and interpreting data.",
            "Mean, median, and mode are different ways to describe the center of data.",
            "Probability helps us understand uncertainty and make predictions.",
            "Statistics are used in science, business, and everyday decision-making."
        }
    },
    history = {
        ancient_civilizations = {
            "Ancient civilizations like Egypt, Greece, and Rome shaped human history.",
            "The Egyptians built pyramids and developed hieroglyphic writing.",
            "Ancient Greece contributed to philosophy, democracy, and the arts.",
            "The Roman Empire influenced law, government, and engineering."
        },
        world_wars = {
            "World War I (1914-1918) involved many nations and introduced modern warfare.",
            "World War II (1939-1945) was the deadliest conflict in human history.",
            "The wars led to significant political, social, and technological changes.",
            "The United Nations was created after WWII to promote peace and cooperation."
        },
        exploration = {
            "The Age of Exploration (15th-17th centuries) expanded European knowledge of the world.",
            "Explorers like Columbus, Magellan, and Cook mapped unknown territories.",
            "Exploration led to cultural exchange, trade, and colonization.",
            "Modern exploration continues in space, oceans, and remote regions."
        },
        inventions = {
            "The printing press (1440) revolutionized information sharing and education.",
            "The Industrial Revolution (1760-1840) transformed manufacturing and society.",
            "The Internet (1960s) created a global network for communication and information.",
            "Inventions continue to shape how we live, work, and communicate."
        }
    },
    entertainment = {
        movies = {
            "Movies combine storytelling, visual effects, and sound to create entertainment.",
            "The film industry produces thousands of movies each year worldwide.",
            "Different genres include action, comedy, drama, horror, and science fiction.",
            "Movies can entertain, educate, and inspire audiences."
        },
        music = {
            "Music is organized sound that can express emotions and tell stories.",
            "Different genres include rock, pop, classical, jazz, and electronic music.",
            "Musical instruments produce sounds through vibration and resonance.",
            "Music has been part of human culture for thousands of years."
        },
        games = {
            "Games provide entertainment, challenge, and social interaction.",
            "Video games combine technology, art, and storytelling.",
            "Board games and card games have been enjoyed for centuries.",
            "Games can develop skills like strategy, cooperation, and problem-solving."
        },
        sports = {
            "Sports involve physical activity, competition, and skill development.",
            "Popular sports include football, basketball, soccer, and tennis.",
            "Sports promote fitness, teamwork, and fair play.",
            "Professional sports are a major entertainment industry worldwide."
        }
    }
}

-- Response patterns for different question types
local responsePatterns = {
    what = {
        "That's a great question about %s!",
        "Let me explain %s for you.",
        "Here's what I know about %s:",
        "I'd be happy to tell you about %s."
    },
    how = {
        "Here's how %s works:",
        "Let me explain the process of %s:",
        "The way %s happens is:",
        "I'll break down how %s works:"
    },
    why = {
        "The reason for %s is:",
        "Here's why %s happens:",
        "Let me explain why %s:",
        "The explanation for %s is:"
    },
    when = {
        "The timing of %s is:",
        "Here's when %s occurs:",
        "The period for %s is:",
        "Let me tell you when %s happens:"
    },
    where = {
        "The location of %s is:",
        "Here's where %s can be found:",
        "The place for %s is:",
        "Let me tell you where %s is located:"
    }
}

-- Input validation function
local function validateInput(input)
    if not input then return false, "No input provided" end
    if type(input) ~= "string" then return false, "Invalid input type" end
    if string.len(input) == 0 then return false, "Empty input" end
    if string.len(input) > 1000 then return false, "Input too long" end
    
    -- Sanitize input - remove dangerous characters
    local sanitized = string.gsub(input, "[<>\"']", "")
    if sanitized ~= input then
        print("Warning: Input sanitized")
    end
    
    return true, sanitized
end

-- Get specific knowledge response
function KnowledgeBase:getResponse(category, topic)
    if not category or not topic then
        print("Warning: Invalid category or topic")
        return nil
    end
    
    if not knowledge[category] then
        print("Warning: Category not found:", category)
        return nil
    end
    
    if not knowledge[category][topic] then
        print("Warning: Topic not found:", topic)
        return nil
    end
    
    local responses = knowledge[category][topic]
    if responses and #responses > 0 then
        return responses[math.random(1, #responses)]
    end
    
    return nil
end

-- Find relevant information based on input
function KnowledgeBase:findRelevantInfo(input)
    if not input then
        print("Warning: No input provided for knowledge search")
        return nil
    end
    
    local inputLower = string.lower(input)
    local relevantInfo = {}
    
    -- Search through all categories and topics
    for category, topics in pairs(knowledge) do
        for topic, responses in pairs(topics) do
            -- Check if input contains topic keywords
            if string.find(inputLower, topic:gsub("_", " ")) then
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

-- Get response pattern based on question type
function KnowledgeBase:getResponsePattern(questionType)
    if not questionType then
        return "Here's what I know about that:"
    end
    
    local patterns = responsePatterns[questionType]
    if patterns and #patterns > 0 then
        return patterns[math.random(1, #patterns)]
    end
    
    return "Here's what I know about that:"
end

-- Analyze question type
function KnowledgeBase:analyzeQuestion(input)
    if not input then
        return "general"
    end
    
    local inputLower = string.lower(input)
    
    local questionTypes = {
        what = {"what", "what is", "what are", "what does", "what do"},
        how = {"how", "how does", "how do", "how to", "how can"},
        why = {"why", "why is", "why are", "why does", "why do"},
        when = {"when", "when is", "when are", "when does", "when do"},
        where = {"where", "where is", "where are", "where does", "where do"}
    }
    
    for questionType, patterns in pairs(questionTypes) do
        for _, pattern in ipairs(patterns) do
            if string.find(inputLower, pattern) then
                return questionType
            end
        end
    end
    
    return "general"
end

-- Generate intelligent response
function KnowledgeBase:generateIntelligentResponse(keywords)
    if not keywords or type(keywords) ~= "table" then
        print("Warning: Invalid keywords for intelligent response")
        return ""
    end
    
    local response = ""
    
    -- Search for relevant information
    local relevantInfo = self:findRelevantInfo(table.concat(keywords, " "))
    
    if relevantInfo and #relevantInfo > 0 then
        -- Use the most relevant response
        local bestMatch = relevantInfo[1]
        if bestMatch and bestMatch.response then
            response = bestMatch.response
        end
    end
    
    -- If no specific knowledge found, try general responses
    if response == "" then
        local generalTopics = {"greetings", "farewells"}
        for _, topic in ipairs(generalTopics) do
            local generalResponse = self:getResponse("general", topic)
            if generalResponse then
                response = generalResponse
                break
            end
        end
    end
    
    return response
end

-- Get random fact
function KnowledgeBase:getRandomFact()
    local allFacts = {}
    
    -- Collect all facts from knowledge base
    for category, topics in pairs(knowledge) do
        for topic, responses in pairs(topics) do
            for _, response in ipairs(responses) do
                table.insert(allFacts, {
                    category = category,
                    topic = topic,
                    response = response
                })
            end
        end
    end
    
    if #allFacts > 0 then
        local randomFact = allFacts[math.random(1, #allFacts)]
        return randomFact.response
    end
    
    return "I'm here to help you learn and explore!"
end

-- Get available categories
function KnowledgeBase:getCategories()
    local categories = {}
    for category, _ in pairs(knowledge) do
        table.insert(categories, category)
    end
    return categories
end

-- Get topics in a category
function KnowledgeBase:getTopics(category)
    if not category or not knowledge[category] then
        return {}
    end
    
    local topics = {}
    for topic, _ in pairs(knowledge[category]) do
        table.insert(topics, topic)
    end
    return topics
end

-- Add new knowledge
function KnowledgeBase:addKnowledge(category, topic, response)
    if not category or not topic or not response then
        print("Warning: Invalid parameters for adding knowledge")
        return false
    end
    
    if not knowledge[category] then
        knowledge[category] = {}
    end
    
    if not knowledge[category][topic] then
        knowledge[category][topic] = {}
    end
    
    table.insert(knowledge[category][topic], response)
    return true
end

-- Constructor
function KnowledgeBase:new()
    local kb = {}
    setmetatable(kb, { __index = KnowledgeBase })
    return kb
end

return KnowledgeBase