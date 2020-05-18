local settings = require("./settings")
local Queue = require("./Queue")
local common = require("./common")


local modem = peripheral.wrap( settings.modemSide )
modem.open(settings.modemChannel)

local monitor = peripheral.wrap( settings.screenSide )
monitor.setTextScale(settings.screenScale)
--get screen size
local w, h = monitor.getSize()
local padding = 1;

local platforms = {} -- departures array 

local alertQueue = Queue:new();


function buildDepartures() 
    monitor.setCursorPos(1+padding,1)
    monitor.clearLine()
    monitor.write("Platform")
    monitor.setCursorPos(w-(10+padding),1) --5 is the length of the word departures 
    monitor.write("Departures")
    
    local y=3
    --show platforms with destinations at the top
    for i,pf in ipairs(platforms) do
        if pf.destination ~= nil then 
            monitor.setCursorPos(1+padding,y)
            monitor.clearLine()

            
            -- print words out
            monitor.write(pf.name .. ": " .. pf.destination)


            y=y+1
        end --if
    end --for
    --platforms with no destination 
    for i,pf in ipairs(platforms) do
        if pf.destination == nil then 
            monitor.setCursorPos(1+padding,y)
            monitor.clearLine()

            
            -- print words out
            monitor.write(pf.name .. ": ...")
            
            y=y+1
        end --if
    end --for
    
end -- buildDepartures

--adds to alert queue and 
function alert(message, color, holdTime) 
    --add to queue
    local queueObj = {message=message, color=color, holdTime=holdTime}
    alertQueue:enqueue(queueObj)

    if alertQueue:size() == 1 then 
        runAlerts()
    end -- if
    
end -- alert

--only to be used with alert()
function runAlerts() 
    --work on front of queue 
    local alertParams = alertQueue:front()

    local oldterm = term.redirect( monitor )

    for y=h,1,-1 do --animate box
        paintutils.drawBox(1,y,w,y+1, alertParams.color)
        common.wait(0.1, handleMessages) -- non event blocking wait
    end -- for
    local oldx, oldy = term.getCursorPos()
    term.setCursorPos(math.floor((w/2)-(string.len(alertParams.message)/2)+0.5),h/2)
    term.write(alertParams.message)
    term.setCursorPos(oldx,oldy)

    term.redirect(oldterm)
    if alertParams.holdTime ~= nil then 
        common.wait(alertParams.holdTime, handleMessages)--dont clear for holdTime 
    end -- if
    alertQueue:dequeue() -- pop from front

    --check if we need to run this again 
    if alertQueue:size() > 0 then 
        runAlerts()
    else -- redraw main screen 
        --buildDepartures()
    end -- if

end -- runAlerts 


--actually handles a raw message.  use with the common.wait command 
function handleMessages(rawEvent)
    if rawEvent[1] == "modem_message" then -- only run if modem message 
        local event, modemSide, senderChannel, 
                replyChannel, message, senderDistance = unpack(rawEvent)
        if message ~= nil and message.yardID == settings.yardID and message.stationID == settings.stationID then
            print("Directive: " .. message.directive .. " FROM: " .. message.computerType)
            if message.computerType == "loading_platform" then

                if message.directive == "connect_infoboards" then 
                    platforms[message.payload.priority] = {name=message.payload.platformName, destination=nil, trainPresent=message.payload.trainPresent} --save device data
                    if alertQueue:size() == 0 then 
                        buildDepartures()
                    end -- if 
                end -- if (directive connect)
                
                if message.directive == "train_status" then 
                    if platforms[message.payload.priority].destination == nil and message.payload.destination ~=nil then --departure!
                        alert("New Departure", colors.red, 0.5)
                        alert("Platform "..platforms[message.payload.priority].platformName, colors.blue, 1)
                    end --if
                    platforms[message.payload.priority].destination = message.payload.destination
                    platforms[message.payload.priority].trainPresent = message.payload.trainPresent
                    -- update screen 
                    buildDepartures()
                end -- if directive train_status
            end -- if commputer type
        end -- if
    end -- if 
end -- handleMessages

function listenForMessages()
    while true do 
        local event = {os.pullEvent("modem_message")}
        handleMessages(event)
    end -- while 
end --function 


function main() 
    --clear the screen
    monitor.clear()
    local oldterm = term.redirect( monitor )
    paintutils.drawFilledBox(1,1,w,h, colors.black)
    term.redirect(oldterm)

    

    alert("Connecting", colors.red)
    common.sendMessage("reconnect", nil) -- notify all child computers to reconnect

    
end -- main

parallel.waitForAll(main, listenForMessages)