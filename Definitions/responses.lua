Decision = {}

function Decision:new()
   local d = setmetatable({}, { __index = Decision })

   return d
end



function Decision:greeting()
   local response = {
      "Hi there.",
      "Hello.",
      "Good day.",
      "Hello there, Master Caleb.",
   }
   return response[math.random(1,#response)]
end

function Decision:goodbye()
   local response = {
      "Bye, now.",
      "Goodnight.",
      "See you later!"
   }
   return response[math.random(1,#response)]
end

function Decision:affirmation()
   local response = {
      "Of course!",
      "Definitely.",
      "Sure thing!",
      "Yes.",
      "Absolutely!",
   }
   return response[math.random(1,#response)]
end

function Decision:negative()
   local response = {
      "No.",
      "Nope.",
      "Absolutely not.",
   }
   return response[math.random(1,#response)]
end

function Decision:randomAnswer()
   local rand = math.random(1, 2)
   local randAnswer
   if rand == 1 then
      randAnswer = self:affirmation()
   else
      randAnswer = self:negative()
   end
   return "I'm going to say... " .. randAnswer
end



return Decision
