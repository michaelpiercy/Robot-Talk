local framework = {

   displayData = function(target)
      local instructions, indexToPrint = target.instructions, target.speechIndex
      local positionCount = 0
      local function addLetter()
         if positionCount<=string.len(instructions[indexToPrint]) then
            positionCount = positionCount + 1

            -- if positionCount is less than or equal to number of letters in 'instructions[indexToPrint]'
            local letter = string.sub(instructions[indexToPrint], positionCount, positionCount) -- get the current letter
            local letterLabel = display.newText(target.speechBubble,letter,10*positionCount,20*indexToPrint,nil,12) -- place the letter
            letterLabel.alpha = 0;

            -- display the label and update the function after the completion of transition
            transition.to(letterLabel,{time = target.typeSpeed, alpha=1, onComplete=addLetter})
         end
      end
      addLetter()
      target.speechIndex = target.speechIndex + 1
      return true
   end,

   speak = function(event)
      local indexToPrint = event.target.speechIndex

      if indexToPrint <= table.maxn(event.target.instructions) then
         event.target.framework.displayData(event.target)
      else
         display.remove(event.target.speechBubble)
         event.target.speechBubble = display.newGroup()
         event.target.speechIndex = 1
         event.target.instructions = {
            "Loading... Caleb's Robot",
            "Robot Sequence Initiated...",
            Decision:new():greeting(),
            Decision:new():randomAnswer(),
            "My answer is... " .. Decision:new():affirmation(),
            "My answer is... " .. Decision:new():negative(),
            Decision:new():goodbye(),
         }
      end
            indexToPrint = indexToPrint + 1
   end

}
return framework
