local settings = require("./settings")
local Queue = require("./Queue")
--local common = require("./common")


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
    term.redirect( monitor )

    for y=h,1,-1 do --animate box
        paintutils.drawFilledBox(1,y,w,y+1, color)
    end -- for
    term.setCursorPos((w/2)-(message.len()/2),h/2)
    term.write(message)

    term.restore()
end -- alert

function main() 
    sleep(5)
    alert("Test", colors.red)
end -- main