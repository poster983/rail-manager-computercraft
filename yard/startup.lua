local settings = require("./settings")
local common = require("./common")
local screen = require("./screen")
local brain = require("./brain")




function handleNetworkEvents(event)
    if event[1] == "modem_message" then 
        local event, modemSide, senderChannel, replyChannel, message, senderDistance = unpack(event)
        if message ~= nil and message.networkID == settings.networkID then -- this is a message for us 
            print("Directive: " .. message.directive .. " FROM: " .. message.computerType)
            
            --computer agnostic directives
            if message.directive == "get_yard_status" and (message.to == nil or message.to = settings.stationID) then 
                local resp = {platforms=brain.platformStatus()}
                common.sendMessage("yard_status", resp, message.stationID)
                return;
            end -- if yard status

        end --if
    end --if

end -- function

function handleEvents(event) 
    
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
      catchEvents()
  end -- main 
  
  main()