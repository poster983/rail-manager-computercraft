local settings = require("./settings")
local common = require("./common")
local screen = require("./screen")
local brain = require("./brain")

local buttons = {}


local monitor = peripheral.wrap( settings.screenSide )

--listen for a click event 
function listenForClick() 
    while true do 
      local event = button.await(buttons)
      if event ~= nil and event.type == "destination" then 
        brain.newDestination(event.value)
      end -- if 
      if event ~= nil and event.type == "command" then 
        --Pagenation
        if event.value == "next" then 
          buttons = screen.page.next()
        end -- if
        if event.value == "previous" then 
          buttons = screen.page.prev()
        end -- if

      end -- if 

      if event ~= nil and event.type == "options" then 

        if event.value == "restock" then 
          brain.restock()
          
        end -- if
      
      end

    end -- while
  end -- function 



function handleScreenEvent(event)
  if event[1] == "job_count" then --update jobcount
    screen.printJobCount(event[2])
  end -- event jobcount
end--handle screen event



function handleEvents(event) 
  handleScreenEvent(event)
  brain.handleEvents(event)

end -- handle events 


function catchEvents() 
  while true do 
    local event = {os.pullEvent()}
    handleEvents(event)

  end --while 

end -- catchEvents


function main() 
    brain.main()
    monitor.clear()
    buttons = screen.build()
    parallel.waitForAll(catchEvents, listenForClick)
end -- main 

main()