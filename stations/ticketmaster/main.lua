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
    if pf.trainPresent == true and pt.destination == nil then -- handle present trains and immediate departures 
      print("Send Destination to computer ")
      --Send destination info to that platform
      if summoned:size() > 0 then --dequeue from summoned first
        platforms[i].destination = summoned:dequeue()
      else --dequeue from main jobs
        platforms[i].destination = jobs:dequeue()
      end --if else
      screen.printJobCount(jobs:size() + summoned:size()) -- update screen
      return;
    end --if 
    if pf.trainPresent == false then 
      platformEmpty = true
    end -- if
  end -- for 

  if platformEmpty then --call a train
    if jobs:size() ~= 0 then 
      --SEND CALL FOR TRAIN FROM HUB TODOOOO
      print("Call Train")
      summoned:enqueue(jobs:dequeue()) --move to summoned queue
    end -- if

  end --if

end -- nextjob


--adds jobs to the queue
function newDestination(destination)
  print("Selected: " .. destination)
  if platforms == {} then --if no loading platforms have connected
    print("No loading platforms are connected")
    return;
  end -- if 

  jobs:enqueue(destination)
  screen.printJobCount(jobs:size())

  -- try and run the job
  nextJob()

end --function

function listenForClick() 
  while true do 
    local event = button.await(buttons)
    if(event ~= nil and event.type = "destination") then 
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
          platforms[message.payload.priority] = {platformName=message.payload.platformName, trainCalled=false, trainPresent=message.payload.trainPresent} --save device data
          
          common.sendMessage(message.payload.priority..":connect", settings.routes) -- send routes to loading platforms 
        end -- if (directive)
      end -- if (computer type)

    end -- if
  end -- while
end -- function


function main()
  monitor.clear()
  buttons = screen.buildButtons()

  parallel.waitForAll(listenForClick, listenForMessages)
end -- function

--start program
main()