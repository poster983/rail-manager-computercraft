local settings = require("./settings")
local common = require("./common")
local brain = require("./brain")


function restock()
    local trainsRequested = 0;
    local curr = brain.yard:iterator()
    local platforms = brain.platformStatus()
end --restock

function sendYardStatus(to)
    print("Sent Yard Status")
    local resp = {platforms=brain.platformStatus()}
    common.sendMessage("yard_status", resp, to)
end --sendYardStatus

function handleNetworkEvents(event)
    if event[1] == "modem_message" then 
        local event, modemSide, senderChannel, replyChannel, message, senderDistance = unpack(event)
        if message ~= nil and message.networkID == settings.networkID then -- this is a message for us 
            --print("Directive: " .. message.directive .. " FROM: " .. message.computerType)
            
            --computer agnostic directives
            if message.directive == "get_yard_status" and (message.to == nil or message.to == settings.stationID) then 
                sendYardStatus(message.stationID)
                return;
            end -- if yard status


            --[[STATION DIRECTIVES]]

            if message.stationID == settings.stationID then
                
                if message.directive == "train_status" then --send yard status update to all computers!
                    sendYardStatus()
                    return;
                end --if

            end -- if station directive

        end --if
    end --if

end -- function

function handleBrainEvent(event)
    if event[1] == "setDestination" then --update yard status
        sendYardStatus()
        return;
    end -- event jobcount
end--function handleBrainEvent

function handleEvents(event) 
    handleBrainEvent(event)
    handleNetworkEvents(event)
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

      sendYardStatus()
      catchEvents()
  end -- main 
  
  main()