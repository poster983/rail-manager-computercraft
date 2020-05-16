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




function main() 
    monitor.clear()
    paintutils.drawFilledBox(1,1,w,h, colors.black)
    --sleep(5)
    --alert("Test", colors.red)
end -- main
main()
