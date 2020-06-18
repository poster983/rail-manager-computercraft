local Yard = {}

function Yard:new (o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self._front = nil
   self._size = 0
   return o
end

--sorts yards by distance
--platforms: {total=int, filled=int, available=int}
function Yard:add (stationID, distance, platforms)
    local data = {distance=distance, stationID=stationID, platforms=platforms}
    local node = {}
    node.data = data
    node.next = nil

    self._size = self._size+1

    --edge case for new list
    if self._front == nil then 
        self._front = node
        return
    end -- if 

    --edge case for smaller than _front
    if self._front.data.distance > distance then 
        node.next = self._front
        self._front = node
        return 
    end --if


    --sort algo 
    local curr = self._front.next
    local prev = self._front
    while curr ~= nil do 
        

        if curr.data.distance > distance then -- insert
            node.next = curr
            prev.next = node
            return 
        end -- if

        curr = curr.next
        prev = prev.next
    end --while
    prev.next = node
end -- add


--updates a yard's platform values.  returns true if it worked, false if not
function Yard:update(stationID, platforms) 
    local curr = self._front
    while curr ~= nil do
        if curr.data.stationID == stationID then 
            curr.data.platforms = platforms
            return true
        end -- if
        curr = curr.next
    end --while 
    return false
end -- update

--deletes a yard.  returns true if deleted (if it existed), false if not
function Yard:remove(stationID) 
    if self._front == nil then 
        return false
    end -- if 

    --edge case for front
    if self._front.data.stationID == stationID then 
        self._front = self._front.next
        self._size = self._size-1
        return true
    end -- if 

    local curr = self._front.next
    local prev = self._front
    while curr ~= nil do
        if curr.data.stationID == stationID then 
            prev.next = curr.next
            self._size = self._size-1
            return true
        end -- if
        prev = prev.next
        curr = curr.next
    end --while 
    return false
end -- update

--returns the data object if the station exists nil if no station is found 
function Yard:get(stationID)  
    local curr = self._front
    while curr ~= nil do
        if curr.data.stationID == stationID then 
            return curr.data
        end -- if
        curr = curr.next
    end --while 
    return nil
end 

--if there is a spot avalable, then return the station ID, if not return nil
function Yard:receive()
    local curr = self._front
    while curr ~= nil do
        if curr.data.platforms.filled < curr.data.platforms.total then 
            return curr.data.stationID
        end -- if 

        curr = curr.next
    end -- while 
    return nil
end -- closest

--returns the closest avalable stationID (closest yard) to send its trains. I.E, the avalable number of avalable trains is > 0.  returns nil if there are no yards
function Yard:send()
    local curr = self._front
    while curr ~= nil do
        if curr.data.platforms.available > 0 then 
            return curr.data.stationID
        end -- if 

        curr = curr.next
    end -- while 

    return nil
end -- closest



--Getter
function Yard:iterator() 
    if self._front == nil then 
        return nil;
    end -- if
    return self._front;
end --iterator

function Yard:size() 
    return self._size;
  end --size

return Yard