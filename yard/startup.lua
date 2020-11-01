local settings = require("./settings")
local common = require("./common")
local brain = require("./brain")

-- restocks a train when the station is low
function restock()
    local trainsRequested = 0;
    --local curr = brain.yard:iterator()
    local platforms = brain.platformStatus()
    if platforms.avalable == 0 then 
    	local closest = brain.yard:send(true)
    	brain.requestRemote(closest)
    end 
end --restock

function sendYardStatus(to)
    print("Sent Yard Status")
    local resp = {platforms=brain.platformStatus()}
    common.tprint(resp)
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

                if message.computerType == "loading_platform" and message.directive == "connect_parent" then -- Loading platform!
                        sendYardStatus()
                end
                
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
    end -- event jobcount
end--function handleBrainEvent

function handleEvents(event) 
    handleBrainEvent(event)
    brain.handleEvents(event)
    --handleBrainEvent(event)
    handleNetworkEvents(event)
    
  
  end -- handle events 
  
  
  function catchEvents() 
    while true do 
      local event = {os.pullEvent()}
      
      handleEvents(event)
  
    end --while 
  
  end -- catchEvents
  
  
  function main() 
      parallel.waitForAll(catchEvents, brain.main, sendYardStatus)
  end -- main 
  
  main()