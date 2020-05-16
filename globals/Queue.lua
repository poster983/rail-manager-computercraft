--Simple single linked list queue implementation in lua
local Queue = {}

function Queue:new (o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self._back = nil
   self._front = nil
   self._size = 0
   return o
end

--adds to end of queue 
function Queue:enqueue(data)
  local queueObject = {}
  queueObject.data = data;
  queueObject.next = nil
  self._size = self._size + 1

  if self._back == nil then --new Queue
    self._front = queueObject
    self._back = queueObject
    return 
  end --if
  --normal insert
  self._back.next = queueObject --set old rear next to the new rear 
  self._back = queueObject
end -- enqueue

-- remove from front of queue. Returns removed element 
function Queue:dequeue() 
  if self._size == 0 then --empty queue. do nothing
    return nil;
  end --if 
  local temp = self._front.data
  self._front = self._front.next; --set the next value to the new front 
  if self._front == nil then --if this is the last element set back to nil
    self._back = nil;
  end -- if

  self._size = self._size -1;

  return temp; --return dequeued element

end -- dequeue 


--getters 

function Queue:front() 
  if self._front == nil then 
    return nil;
  end -- if
  return self._front.data;
end --frony

function Queue:back() 
  if self._back == nil then 
    return nil;
  end -- if
  return self._back.data;
end --back

function Queue:size() 
  return self._size;
end --size


return Queue;