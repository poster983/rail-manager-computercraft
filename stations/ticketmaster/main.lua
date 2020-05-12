--Entrypoint for stations destination chooser
-- REQUIRES https://github.com/Siarko/ButtonApi
-- WGET it from: https://raw.githubusercontent.com/Siarko/ButtonApi/master/button
local station = require("./settings")
local common = require("./common")
os.loadAPI("button")

local modem = peripheral.wrap( "top" )

modem.open(station.modemChannel)

local monitor = peripheral.wrap( station.screenSide )
button.setMonitor(monitor)
--get screen size
local w, h = monitor.getSize()
local routeKeys = common.getTableKeys(station.routes);

--[[local w = 19
local h = 19]]

local buttons = {}
local buttonPadding = 2;
local buttonWidth = (w/2);
local buttonHeight = (h/table.getn(routeKeys));

--build the buttons 
function buildButtons()
  print(buttonWidth, buttonHeight)
  local x=0 --col
  local y=0 --row
  for k, v in pairs(station.routes) do
    local bx = buttonPadding --button x 
    local by = buttonPadding --button y
    --find the coords of the button
    --find by 
    by = by + (y*buttonHeight)
    --bx
    if x == 1 then -- row 2
      bx = bx + buttonWidth;
      x = 0;
      y = y+1;
    else 
      x = 1;
    end --if
    
    --add button
    --t:add(k, nil, bx, by, bx+buttonWidth-buttonPadding, by+buttonHeight-buttonPadding, colors.red, colors.lime)
    local but = button.create(k)
    but.setPos(bx,by)
    but.setSize(buttonWidth-buttonPadding,buttonHeight-buttonPadding)
    but.onClick(function() setDestination(k) end)
    --add to array
    buttons[#buttons+1] = but;
    print(k .. ": x: ".. bx .. " y: " .. by)
  end --for
  
end --function

buildButtons()

function setDestination(destination)
  print("Selected: " .. destination)

  --check if any trains are avalable

end --function

function listenForClick() 
  while true do 
    button.await(buttons)
  end -- while
end -- function 

function listenForMessage()
  while true do 
    local event, modemSide, senderChannel, 
    replyChannel, message, senderDistance = os.pullEvent("modem_message")

    if message ~= nil and message.yardID == station.yardID and message.stationID == station.stationID then -- this is a message for us 
      print("Directive: " .. message.directive)

    end
  end -- while
end -- function


function main()
  monitor.clear()
  while true do --TEST
    print("hi")
    sleep(3)
  end -- while
end -- function

parallel.waitForAll(main, listenForClick, listenForMessage)