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


function listenForMessages() 
  while true do 
    local event, modemSide, senderChannel, 
    replyChannel, message, senderDistance = os.pullEvent("modem_message")

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

      elseif message.computerType == "infoboard" then --infoboard directives
        if message.directive == "reconnect" then -- reconnect message to infoboard
          connectToInfoboards()
        end -- directive reconnect
      end -- if (computer type)

    end -- if
  end -- while
end --listenForMessages

function listenForRedstone() 

  while true do
    os.pullEvent("redstone") -- wait for a "redstone" event

    setTrainStatus(redstone.testBundledInput(settings.cableSide, settings.redstone.trainPresent))


  end -- while 
end -- function listenForRedstone


function setTrainStatus(isPresent) 
  if isPresent ~= trainPresent then 
    if isPresent == false then 
      destination = nil -- reset to nil
    end -- if
    trainPresent = isPresent
    local message = {priority=settings.priority, trainPresent=trainPresent, destination=destination}
    common.sendMessage("train_status", message)
  end -- if
end -- function setTrainStatus

function connectToParent()
  print("Connecting to Parent")
  local message = {platformName=settings.platformName, priority=settings.priority, trainPresent=trainPresent}
  common.sendMessage("connect_parent", message)
end --function 

function connectToInfoboards()
  print("Connecting to Infoboards")
  local message = {platformName=settings.platformName, priority=settings.priority, trainPresent=trainPresent}
  common.sendMessage("connect_infoboards", message)
end --function 

function main() 
    --get routes
    connectToParent()
    connectToInfoboards()
end --main

parallel.waitForAll(main, listenForMessages, listenForRedstone)
