--Entrypoint for stations destination chooser

local settings = require("./settings")
local common = require("./common")
local screen = require("./screen")
local Queue = require("./Queue")



local platforms = {} -- platform IDs and such 
local jobs = Queue:new(); --create new job queue
local summoned = Queue:new(); -- create a new queue for jobs that had trains summoned for them

local send = Queue:new();
local holdTrains = false; 

local lineClearPulse = false;

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
  local numOfPresentTrains = 0 -- total trains in the station
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
    else 
      numOfPresentTrains = numOfPresentTrains +1
    end -- if
  end -- for 

  if platformEmpty and jobs:size() ~= 0 and summoned:size() < table.getn(platforms)-numOfPresentTrains then --call a train
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
  screen.printJobCount(jobs:size() + summoned:size())

  -- try and run the job
  nextJob()

end --function

--tell platform computer to print out the tickets 
function setDestination(priority, destination)
  platforms[priority].destination = destination
  local message = {priority=priority, destination=destination}
  common.sendMessage("setDestination", message)

end -- setDestination

--ADD TO TRAIN SEND QUEUE
function sendTrain(platformPriority) 
  --check if platform is already in the queue
  if platforms[platformPriority].sent == true then 
    return false
  end -- if

  --check if a train is actually present
  if platforms[platformPriority].trainPresent == true then 
    
    send:enqueue(platformPriority)
    print("Waiting to send train at platform " .. platformPriority)
    platforms[platformPriority].sent = true
    
    if holdTrains == false then -- send next train only if it is safe
      sendNextTrain()
      
    end --if 
    return true
  end --if
  return false
end -- send train

--work through the queue 
function sendNextTrain()
  
  holdTrains=false -- reset locker
  if send:size() >0 then
    local pf = send:dequeue() -- pop from queue
    
    platforms[pf].sent = false
    --send train
    print("Sending train on platform  " .. pf)
    common.sendMessage("sendTrain", pf)
    holdTrains = true
  end --if
end --sendNextTrain


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
        if message.directive == "connect_parent" then 
          platforms[message.payload.priority] = {name=message.payload.platformName, destination=nil, trainPresent=message.payload.trainPresent} --save device data
          
          common.sendMessage(message.payload.priority..":connect", settings.routes) -- send routes to loading platforms 
        end -- if (directive connect)
        if message.directive == "train_status" then 
          
          --[[platforms[message.payload.priority].trainReady = message.payload.trainReady;
          if message.payload.trainReady == true and message.payload.destination ~=nil then 
            sendTrain(message.payload.priority);
          end --if ]]

          --ruun next job only if trainPresent has changed
          if message.payload.trainPresent ~= platforms[message.payload.priority].trainPresent then
            --set status value s
            platforms[message.payload.priority].trainPresent = message.payload.trainPresent;
            if message.payload.trainPresent == false then 
              --track no longer has destination
              platforms[message.payload.priority].destination = nil
            end -- if
            nextJob()

          end -- if
        end -- if directive train_status

        if message.directive == "train_ready" then 

          sendTrain(message.payload);

        end -- if train ready 
      end -- if (computer type)

    end -- if
  end -- while
end -- function

function listenForRedstone() 

  while true do
    os.pullEvent("redstone") -- wait for a "redstone" event

    --TEST LINE CLEAR 
    local oldLineClearPulse = lineClearPulse
    lineClearPulse = redstone.testBundledInput(settings.cableSide, settings.redstone.lineClear)
    print("Redstone event: lineClearPulse" )
    if lineClearPulse == false and lineClearPulse ~= oldLineClearPulse then --if pulse is on 
      --line clear 
      sendNextTrain()

    end -- if line clear 




  end -- while 
end -- function listenForRedstone


function main()
  monitor.clear()
  buttons = screen.buildButtons()
  common.sendMessage("reconnect", nil) -- notify all child computers to reconnect
  parallel.waitForAll(listenForClick, listenForMessages, listenForRedstone)
end -- function

--start program
main()