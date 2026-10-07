MIN_ARR_IDX = 1 -- array start from 1
function insert_sort(arr, isDesc)
  local i,j,k    -- ‘local’ like ‘var’ in js , it indicates a local variable
  local nLen = #arr

  if nLen == 0 or nLen == 1 then
    return arr
  end

  for i = MIN_ARR_IDX + 1, nLen do
    local tmp = arr[i]

    for j = i, MIN_ARR_IDX + 1, -1 do
        if isDesc then
		  if tmp < arr[j - 1] then break end
		else
		  if tmp > arr[j - 1] then break end
		end
        arr[j] = arr[j-1]
        arr[j-1] = tmp
    end

  end
  return arr
end

arr = insert_sort({31, 22, 13, 54, 45}, true)
-- print 
print(table.concat(arr, ", "))  
arr = insert_sort({31, 22, 13, 54, 45}, false)
print(table.concat(arr, ", "))  