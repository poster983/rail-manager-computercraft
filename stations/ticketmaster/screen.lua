-- REQUIRES https://github.com/Siarko/ButtonApi
-- WGET it from: https://raw.githubusercontent.com/Siarko/ButtonApi/master/button
local settings = require("./settings")
local common = require("./common")
os.loadAPI("button")

local screen = {}


local monitor = peripheral.wrap( settings.screenSide )
monitor.setTextScale(0.9)
button.setMonitor(monitor)
--get screen size
local w, h = monitor.getSize()

--removes routes that have the hide=true property 
function filterRoutes() 
  local out = {}
  for k, v in pairs(settings.routes) do
    --add to new table if it should not be hidden
    if v["hide"] ~= true then
      out[k] = v
    end
  end
  return out
end

--build the buttons 
screen.buildButtons = function()
  local routes = filterRoutes()
  local routeKeys = common.getTableKeys(routes);
  local buttons = {}
  local buttonPadding = 2;
  local buttonWidth = (w/2);
  local buttonHeight = ((h/table.getn(routeKeys))*2)-buttonPadding;

  print(buttonWidth, buttonHeight)
  local x=0 --col
  local y=0 --row
  for k, v in pairs(routes) do
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
    but.setColor(settings.buttonColor)
    but.setBlinkColor(settings.buttonClickColor)
    but.setSize(buttonWidth-buttonPadding,buttonHeight-buttonPadding)
    but.onClickReturn({type="destination", value=k})
    --add to array
    buttons[#buttons+1] = but;
    print(k .. ": x: ".. bx .. " y: " .. by)
  end --for
  return buttons;
end --function


--Full screen alert with text 
screen.alert = function(text, textColor, bgColor, clearColor, time) 


end -- function alert 

--show current jobs
screen.printJobCount = function(count)
    monitor.setCursorPos(1,1)
    monitor.clearLine()
    if count == 1 then -- singular 
        monitor.write(count .. " Train incoming")
    end 
    if count > 1 then --plural 
        monitor.write(count .. " Trains incoming")
    end 
end --printJobCount




return screen;