--logic brain for sending trains.  Used by ticketmaster and yardmaster
--Entrypoint for stations destination chooser
local brain = {};
local settings = require("./settings")
local common = require("./common")
--local screen = require("./screen")
local Queue = require("./Queue")



brain.platforms = {} -- platform IDs and such 
brain.jobs = Queue:new(); --create new job queue
brain.summoned = Queue:new(); -- create a new queue for jobs that had trains summoned for them

brain.send = Queue:new();

brain.closestYard = "Big Yard"

local trainLeaving = false; 

local lineClearPulse = false;
local clearPlatformPulse = false;

local modem = peripheral.wrap( settings.modemSide )
modem.open(settings.modemChannel)


--checks the queue and sees if any trains are avalable
function nextJob()
  if brain.jobs:size() == 0 and brain.summoned:size() == 0 then --check if queue is empty 
    return
  end --if 

  local platformEmpty = false --there exists some empty platform that we could call a train to
  local numOfPresentTrains = 0 -- total trains in the station
  --check if any trains are avalable
  for i,pf in ipairs(brain.platforms) do
    if pf.trainPresent == true and pf.destination == nil then -- handle present trains and immediate departures 
      print("Send Destination to computer ")
      --Send destination info to that platform
      local destination = nil
      if brain.summoned:size() > 0 then --dequeue from brain.summoned first
        destination = brain.summoned:dequeue()
      else --dequeue from main jobs
        destination = brain.jobs:dequeue()
      end --if else
      setDestination(i, destination);
      --platform number, destination
      os.queueEvent( "set_destination", i, destination );
      os.queueEvent( "job_count", brain.jobs:size() + brain.summoned:size() );
      --screen.printJobCount(brain.jobs:size() + brain.summoned:size()) -- update screen
      return;
    end --if 
    if pf.trainPresent == false then 
      platformEmpty = true
    else 
      numOfPresentTrains = numOfPresentTrains +1
    end -- if
  end -- for 

  if platformEmpty and brain.jobs:size() ~= 0 and brain.summoned:size() < table.getn(brain.platforms)-numOfPresentTrains then --call a train
      --SEND CALL FOR TRAIN FROM HUB TODOOOO
      print("Call Train")
      brain.summoned:enqueue(brain.jobs:dequeue()) --move to brain.summoned queue
      return
  end --if

  print("Will do nothing")

end -- nextjob


--adds jobs to the queue
brain.newDestination = function(destination)
  print("Selected: " .. destination)
  if next(brain.platforms) == nil then --if no loading platforms have connected
    print("No loading platforms are connected")
    return;
  end -- if 

  brain.jobs:enqueue(destination)
  os.queueEvent( "job_count", brain.jobs:size() + brain.summoned:size() );

  -- try and run the job
  nextJob()

end --function

--tell platform computer to print out the tickets 
function setDestination(priority, destination)
  brain.platforms[priority].destination = destination
  local message = {priority=priority, destination=destination}
  common.sendMessage("setDestination", message)

end -- setDestination

--ADD TO TRAIN SEND QUEUE
--opts: {cut: Bool - cuts to front of queue}
function sendTrain(platformPriority, opts) 
  if opts == nil then 
    opts = {}
  end -- default
  --check if platform is already in the queue
  if brain.platforms[platformPriority].sent == true then 
    return false
  end -- if

  --check if a train is actually present
  if brain.platforms[platformPriority].trainPresent == true then 
    
    if opts.cut == true then 
      brain.send:cut(platformPriority)
    else
      brain.send:enqueue(platformPriority)
    end -- if
    print("Waiting to send train at platform " .. platformPriority)
    brain.platforms[platformPriority].sent = true
    
    if trainLeaving == false then -- send next train only if it is safe
      sendNextTrain()
      
    end --if 
    return true
  end --if
  return false
end -- send train

--work through the queue 
function sendNextTrain()
  trainLeaving=false -- reset locker
  if brain.send:size() >0 then
    local pf = brain.send:dequeue() -- pop from queue
    
    brain.platforms[pf].sent = false
    --send train
    print("Sending train on platform  " .. pf)
    common.sendMessage("sendTrain", pf)
    trainLeaving = true
    redstone.setBundledOutput(settings.cableSide, colors.combine(redstone.getBundledOutput(settings.cableSide), settings.redstone.trainLeaving))
    common.wait(0.5, brain.handleEvents)
    redstone.setBundledOutput(settings.cableSide, colors.subtract(redstone.getBundledOutput(settings.cableSide), settings.redstone.trainLeaving))
  end --if
end --sendNextTrain

 
brain.clearPlatform = function() 
  -- find the total number of trains 
  local platformCount = table.getn(brain.platforms);
  local numOfTrains = 0
  local numOfUsedTrains = 0
  for i,pf in ipairs(brain.platforms) do
    if brain.platforms[pf].trainPresent ==true then 
      numOfTrains = numOfTrains+1
    end -- if 
    if brain.platforms[pf].destination == true then
      numOfUsedTrains = numOfUsedTrains+1
    end -- if
  end -- for

  

  if numOfTrains == platformCount and trainLeaving == false then -- trya nd clear the line f all lines are full

    for i,pf in ipairs(brain.platforms) do
      if brain.platforms[pf].destination == false and brain.platforms[pf].trainPresent == true then --only send if the train isnt doing anything
          setDestination(pf, brain.closestYard)
          sendTrain(pf, {cut=true})
          return;

      end -- if 

    end --for
    --fallback just send the last train
    setDestination(numOfTrains, brain.closestYard)
    sendTrain(numOfTrains, {cut=true})
  end --if

end -- clear line 


function handleMessages(event) 
  if event[1] == "modem_message" then 
    local event, modemSide, senderChannel, 
                replyChannel, message, senderDistance = unpack(event)

    if message ~= nil and message.yardID == settings.yardID and message.stationID == settings.stationID then -- this is a message for us 
      print("Directive: " .. message.directive .. " FROM: " .. message.computerType)

      if message.computerType == "loading_platform" then -- Loading platform!
        if message.directive == "connect_parent" then 
          brain.platforms[message.payload.priority] = {name=message.payload.platformName, destination=nil, trainPresent=message.payload.trainPresent} --save device data
          
          common.sendMessage(message.payload.priority..":connect", settings.routes) -- send routes to loading platforms 
        end -- if (directive connect)
        if message.directive == "train_status" then 
          
          --[[platforms[message.payload.priority].trainReady = message.payload.trainReady;
          if message.payload.trainReady == true and message.payload.destination ~=nil then 
            sendTrain(message.payload.priority);
          end --if ]]

          --ruun next job only if trainPresent has changed
          if message.payload.trainPresent ~= brain.platforms[message.payload.priority].trainPresent then
            --set status value s
            brain.platforms[message.payload.priority].trainPresent = message.payload.trainPresent;
            if message.payload.trainPresent == false then 
              --track no longer has destination
              brain.platforms[message.payload.priority].destination = nil
            else  -- train arrived!
              redstone.setBundledOutput(settings.cableSide, colors.combine(redstone.getBundledOutput(settings.cableSide), settings.redstone.trainArriving))
              common.wait(0.5, brain.handleEvents)
              redstone.setBundledOutput(settings.cableSide, colors.subtract(redstone.getBundledOutput(settings.cableSide), settings.redstone.trainArriving))
            end -- if
            nextJob()

          end -- if
        end -- if directive train_status

        if message.directive == "error" then 
          redstone.setBundledOutput(settings.cableSide, colors.combine(redstone.getBundledOutput(settings.cableSide), settings.redstone.error))
          common.wait(0.5, brain.handleEvents)
          redstone.setBundledOutput(settings.cableSide, colors.subtract(redstone.getBundledOutput(settings.cableSide), settings.redstone.error))

          print("Error from loading_platform " .. message.payload.priority .. ": " .. message.payload.message)
        end -- end if error

        if message.directive == "train_ready" then 
          
          sendTrain(message.payload);
          


        end -- if train ready 
      end -- if (computer type)

    end -- if
  end -- if modem message 
end -- function

function handleRedstoneEvent(event) 

  if event[1] == "redstone" then

    --TEST LINE CLEAR 
    local oldLineClearPulse = lineClearPulse
    lineClearPulse = redstone.testBundledInput(settings.cableSide, settings.redstone.lineClear)
    
    if lineClearPulse == false and lineClearPulse ~= oldLineClearPulse then --if pulse is on 
      print("Redstone event: lineClearPulse" )
      --line clear 
      sendNextTrain()

    end -- if line clear 
    

    --TEST Make room pulse  
    local oldClearPlatformPulse = clearPlatformPulse
    clearPlatformPulse = redstone.testBundledInput(settings.cableSide, settings.redstone.clearPlatform)
    
    if clearPlatformPulse == false and clearPlatformPulse ~= oldClearPlatformPulse then --if pulse is on 
      print("Redstone event: clearPlatformPulse" )
      --line clear 
      brain.clearPlatform()

    end -- if line clear 




  end -- if 
end -- function listenForRedstone

--exists for the wait function
brain.handleEvents = function(event) 
  handleRedstoneEvent(event)
  handleMessages(event)
end 

brain.listenForEvents = function() 
  while true do 
    local event = {os.pullEvent()}
    brain.handleEvents(event)
  end -- while 
end -- function


brain.main = function()
  
  common.sendMessage("reconnect", nil) -- notify all child computers to reconnect
end -- function

return brain