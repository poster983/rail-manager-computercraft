--[[
    Loading platform Settings 
    Manages the printing of tickets and informs the ticketmaster or yard computer of train state
]]
local settings = require("./settings");
local common = require("./common");
local printer = peripheral.wrap(settings.printerSide);

local modem = peripheral.wrap( settings.modemSide )
modem.open(settings.modemChannel)

local trainPresent = redstone.testBundledInput(settings.cableSide, settings.redstone.trainPresent);
local trainReady = false;

local destination = nil;
local station = {} --load from network

--Destination is a string matching the station route
-- Returns true if worked, false if failed
function printTickets(destination)
  --create new page
  local route = station.routes[destination]
  for i,junction in ipairs(route) do
    if not printString(junction) then
      return false
    end
  end
  return true;
end


-- Returns true if worked, false if failed
function printString(string)
  local ready = printer.newPage()
  if ready then
    --printer.write(string)
    printer.setPageTitle(string)
    printer.endPage()
  else
    return false
  end
  
  print(string)
  return true
end 


function handleMessages(event) 
  if event[1] == "modem_message" then 
    local event, modemSide, senderChannel, 
                replyChannel, message, senderDistance = unpack(event)

    if message ~= nil and message.yardID == settings.yardID and message.stationID == settings.stationID then -- this is a message for us 
      print("Directive: " .. message.directive .. " FROM: " .. message.computerType)

      if message.computerType == "ticketmaster" then -- Message from ticket master!
        if message.directive == settings.priority..":connect" then 
          station.routes = message.payload -- save routes
           
        end -- if (directive :connect)

        if message.directive == "reconnect" then -- reconnect message to ticket master
          connectToParent()
        end -- directive reconnect

        if message.directive == "setDestination" and message.payload.priority == settings.priority then -- set a destination and print it
          destination = message.payload.destination
          if printTickets(message.payload.destination) == false then 
            common.sendMessage("error", {priority=settings.priority, message="Could not print tickets"})
          end -- if 
        end -- directive reconnect

        if message.directive == "sendTrain" and message.payload == settings.priority then -- Send the train off
          redstone.setBundledOutput(settings.cableSide, colors.combine(redstone.getBundledOutput(settings.cableSide), settings.redstone.sendTrain))
          common.wait(0.5, handleEvents)
          redstone.setBundledOutput(settings.cableSide, colors.subtract(redstone.getBundledOutput(settings.cableSide), settings.redstone.sendTrain))
        end -- end sendtrain

      elseif message.computerType == "infoboard" then --infoboard directives
        if message.directive == "reconnect" then -- reconnect message to infoboard
          connectToInfoboards()
        end -- directive reconnect
      end -- if (computer type)

    end -- if
  end -- if modem_message
end --listenForMessages

function handleRedstoneEvent(event) 

  if event[1] == "redstone" then 
    trainReady = redstone.testBundledInput(settings.cableSide, settings.redstone.trainReady)
    trainPresent = redstone.testBundledInput(settings.cableSide, settings.redstone.trainPresent)
    sendTrainStatus()


  end -- while 
end -- function listenForRedstone

--exists for the wait function
function handleEvents(event) 
  handleRedstoneEvent(event)
  handleMessages(event)
end 

function listenForEvents() 
  while true do 
    local event = {os.pullEvent()}
    handleEvents(event)
  end -- while 
end -- fucntion 


function sendTrainStatus() 

  if trainPresent == false then 
    destination = nil -- reset to nil
  end -- if
  local message = {priority=settings.priority, trainPresent=trainPresent, trainReady=trainReady, destination=destination}
  common.sendMessage("train_status", message)

end -- function setTrainStatus

function connectToParent()
  print("Connecting to Parent")
  local message = {platformName=settings.platformName, trainReady=trainReady,  priority=settings.priority, trainPresent=trainPresent}
  common.sendMessage("connect_parent", message)
end --function 

function connectToInfoboards()
  print("Connecting to Infoboards")
  local message = {platformName=settings.platformName, trainReady=trainReady, priority=settings.priority, trainPresent=trainPresent}
  common.sendMessage("connect_infoboards", message)
end --function 

function main() 
    --get routes
    connectToParent()
    connectToInfoboards()
end --main

parallel.waitForAll(main, listenForEvents)
