Robot = {}

function Robot:new()
   local r = setmetatable({}, { __index = Robot })
   
   return r
end



function Robot:greeting()
   local response = {
      "Hi there.",
      "Hello.",
      "Good day.",
      "Hello there, Master Caleb.",
   }
   return response[math.random(1,#response)]
end

function Robot:goodbye()
   local response = {
      "Bye, now.",
      "Goodnight.",
      "See you later!"
   }
   return response[math.random(1,#response)]
end

function Robot:affirmation()
   local response = {
      "Of course!",
      "Definitely.",
      "Sure thing!",
      "Yes.",
      "Absolutely!",
   }
   return response[math.random(1,#response)]
end

function Robot:negative()
   local response = {
      "No.",
      "Nope.",
      "Absolutely not.",
   }
   return response[math.random(1,#response)]
end

function Robot:randomAnswer()
   local rand = math.random(1, 2)
   local randAnswer
   if rand == 1 then
      randAnswer = self:affirmation()
   else
      randAnswer = self:negative()
   end
   return "I'm going to say... " .. randAnswer
end



return Robot
