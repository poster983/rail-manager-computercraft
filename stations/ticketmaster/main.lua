--Entrypoint for stations destination chooser
-- REQUIRES https://github.com/Siarko/ButtonApi
-- WGET it from: https://raw.githubusercontent.com/Siarko/ButtonApi/master/button
local settings = require("./settings")
local common = require("./common")
local screen = require("./screen")
local Queue = require("./Queue")



local platforms = {} -- platform IDs and such 
local jobs = Queue:new(); --create new job queue
local summoned = Queue:new(); -- create a new queue for jobs that had trains summoned for them

local monitor = peripheral.wrap( settings.screenSide )
local modem = peripheral.wrap( settings.modemSide )
modem.open(settings.modemChannel)

--list of button objects 
local buttons = {};

--checks the queue and sees if any trains are avalable
function nextJob()
  if jobs:size() == 0 and summoned:size() == 0 then --check if queue is empty 
    return
  end --if 

  local platformEmpty = false --there exists some empty platform that we could call a train to

  --check if any trains are avalable
  for i,pf in ipairs(platforms) do
    if pf.trainPresent == true and pf.destination == nil then -- handle present trains and immediate departures 
      print("Send Destination to computer ")
      --Send destination info to that platform
      local destination = nil
      if summoned:size() > 0 then --dequeue from summoned first
        destination = summoned:dequeue()
      else --dequeue from main jobs
        destination = jobs:dequeue()
      end --if else
      setDestination(i, destination);
      screen.printJobCount(jobs:size() + summoned:size()) -- update screen
      return;
    end --if 
    if pf.trainPresent == false then 
      platformEmpty = true
    end -- if
  end -- for 

  if platformEmpty and jobs:size() ~= 0 and summoned:size() <= table.getn(platforms) then --call a train
      --SEND CALL FOR TRAIN FROM HUB TODOOOO
      print("Call Train")
      summoned:enqueue(jobs:dequeue()) --move to summoned queue
      return
  end --if

  print("Will do nothing")

end -- nextjob


--adds jobs to the queue
function newDestination(destination)
  print("Selected: " .. destination)
  if next(platforms) == nil then --if no loading platforms have connected
    print("No loading platforms are connected")
    return;
  end -- if 

  jobs:enqueue(destination)
  screen.printJobCount(jobs:size())

  -- try and run the job
  nextJob()

end --function


function setDestination(priority, destination)
  platforms[priority].destination = destination
  common.sendMessage(priority..":setDestination", destination)

end -- setDestination


function listenForClick() 
  while true do 
    local event = button.await(buttons)
    if event ~= nil and event.type == "destination" then 
      newDestination(event.value)
    end -- if 
  end -- while
end -- function 

function listenForMessages()
  while true do 
    local event, modemSide, senderChannel, 
    replyChannel, message, senderDistance = os.pullEvent("modem_message")

    if message ~= nil and message.yardID == settings.yardID and message.stationID == settings.stationID then -- this is a message for us 
      print("Directive: " .. message.directive .. " FROM: " .. message.computerType)

      if message.computerType == "loading_platform" then -- Loading platform!
        if message.directive == "connect" then 
          platforms[message.payload.priority] = {platformName=message.payload.platformName, destination=nil, trainPresent=message.payload.trainPresent} --save device data
          
          common.sendMessage(message.payload.priority..":connect", settings.routes) -- send routes to loading platforms 
        end -- if (directive connect)
        if message.directive == "train_status" then 
          --ruun next job only if trainPresent has changed
          if message.payload.trainPresent ~= platforms[message.payload.priority].trainPresent then
            --set status values 
            platforms[message.payload.priority].trainPresent = message.payload.trainPresent;
            if message.payload.trainPresent == true then 
              nextJob()
            else 
              --track no longer has destination 
              platforms[message.payload.priority].destination = nil
            end -- if else 

          end -- if

          
          
          
        end -- if directive train_status
      end -- if (computer type)

    end -- if
  end -- while
end -- function


function main()
  monitor.clear()
  buttons = screen.buildButtons()
  common.sendMessage("reconnect", nil) -- notify all child computers to reconnect
  parallel.waitForAll(listenForClick, listenForMessages)
end -- function

--start program
main()