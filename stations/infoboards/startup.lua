local settings = require("./settings")
--local Queue = require("./Queue")
local common = require("./common")


local modem = peripheral.wrap( settings.modemSide )
modem.open(settings.modemChannel)

local monitor = peripheral.wrap( settings.screenSide )
monitor.setTextScale(settings.screenScale)
--get screen size
local w, h = monitor.getSize()
local padding = 1;

local platforms = {} -- departures array 


function buildDepartures() 
    monitor.setCursorPos(1+padding,1)
    monitor.clearLine()
    monitor.write("Platform")
    monitor.setCursorPos(w-(10+padding),1) --5 is the length of the word departures 
    monitor.write("Departures")
    
    local y=3
    for i,pf in ipairs(platforms) do
        
        monitor.setCursorPos(1+padding,y)
        monitor.clearLine()

        -- print words out
        monitor.write(pf.name .. ": " .. pf.destination)

        y=y+1
    end --for
    
end -- buildDepartures

function alert(message, color) 
    local oldterm = term.redirect( monitor )

    for y=h,1,-1 do --animate box
        paintutils.drawBox(1,y,w,y+1, color)
        sleep(0.1)
    end -- for
    local oldx, oldy = term.getCursorPos()
    term.setCursorPos(math.floor((w/2)-(string.len(message)/2)+0.5),h/2)
    term.write(message)
    term.setCursorPos(oldx,oldy)

    term.redirect(oldterm)
end -- alert

function listenForMessages()
    while true do 
        local event, modemSide, senderChannel, 
        replyChannel, message, senderDistance = os.pullEvent("modem_message")
        if message ~= nil and message.yardID == settings.yardID and message.stationID == settings.stationID then
            print("Directive: " .. message.directive .. " FROM: " .. message.computerType)
            if message.computerType == "loading_platform" then

                if message.directive == "connect_infoboards" then 
                    platforms[message.payload.priority] = {name=message.payload.platformName, destination=nil, trainPresent=message.payload.trainPresent} --save device data
                    buildDepartures()
                end -- if (directive connect)
                
                if message.directive == "train_status" then 
                    if platforms[message.payload.priority].destination == nil and message.payload.destination ~=nil then --departure!
                        alert("New Departure", colors.red)
                        sleep(0.5) -- update to be async 
                        alert("Platform "..platforms[message.payload.priority].platformName, colors.blue)
                    end --if
                    platforms[message.payload.priority].destination = message.payload.destination
                    platforms[message.payload.priority].trainPresent = message.payload.trainPresent
                    -- update screen 
                    buildDepartures()
                end -- if directive train_status
            end -- if commputer type
        end -- if
    end -- while 
end --function 


function main() 
    --clear the screen
    monitor.clear()
    local oldterm = term.redirect( monitor )
    paintutils.drawFilledBox(1,1,w,h, colors.black)
    term.redirect(oldterm)

    alert("Connecting", colors.red)
    common.sendMessage("reconnect_infoboards", nil) -- notify all child computers to reconnect

    parallel.waitForAll( listenForMessages)
end -- main
main()
