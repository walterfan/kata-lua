function newCounter ()
   local i = 0
   return function ()
       i = i + 1
       return i
    end
end

function divide_string(str, sep)
    local i, j = string.find(str, sep)
    return string.sub(str, 1, i-1), string.sub(str, j+1,string.len(str))
end

function merge_string(...)
  local strRet = '';
  local t={...}
    for i, v in ipairs(t) do
    strRet = strRet .. v
  end
  return strRet;
end

counter1 = newCounter()
counter2 = newCounter()
print(counter1()) --> 1
print(counter1()) --> 2
print("\n--------------\n")
print(divide_string("hello world", " ")) --> hello, world
print("\n--------------\n")
print(merge_string("walter", ".", "fan")) --> hello world