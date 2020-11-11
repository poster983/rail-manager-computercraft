-- REQUIRES https://github.com/Siarko/ButtonApi
-- WGET it from: https://raw.githubusercontent.com/Siarko/ButtonApi/master/button
local settings = require("./settings")
local common = require("./common")
os.loadAPI("button")

local screen = {}

local currentPage = 0


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

local routes = filterRoutes()
local gRouteKeys = common.getTableKeys(routes);
local numOfRoutes = table.getn(gRouteKeys);

--build the buttons 
screen.buildButtons = function(page)
  if page == nil then 
    page = currentPage
  end -- if

  local conWidth = w
  local conHeight = h-5
  

  -- build page
  local pageRoutes = {}

  local startIndex = (page * settings.maxButtonsPerPage)+1
  local p = startIndex
  for k, v in pairs(pageRoutes) do
    if (startIndex + settings.maxButtonsPerPage) > p then 
      pageRoutes[k] = v
    end -- if

    p=p+1
  end -- for
  

  local routeKeys = common.getTableKeys(pageRoutes);
  

  local numOfColumns = settings.numOfButtonColumns
  local numOfRows = table.getn(routeKeys)/numOfColumns;
  

  local buttons = {}
  local buttonPadding = 2;
  local buttonWidth = (conWidth/numOfColumns);
  -- find how many rows there will be
  --number of routes (MOD) number of columns
  if numOfRows % numOfColumns ~= 0 then
    numOfRows = math.ceil(numOfRows)
  end

  local buttonHeight = conHeight/numOfRows

  print(buttonWidth, buttonHeight)
  local x=0 --col
  local y=0 --row
  for k, v in pairs(pageRoutes) do
    local bx = buttonPadding --button x 
    local by = buttonPadding --button y
    --find the coords of the button
    --find by 
    by = by + (y*buttonHeight)
    bx = bx + (x*buttonWidth);
    --bx
    if x == numOfColumns-1 then -- last col
      
      x = 0;
      y = y+1;
    else 
      x = x + 1;
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


screen.build = function()


end -- function


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