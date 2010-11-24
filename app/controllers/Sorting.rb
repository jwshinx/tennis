module Sorting

def greetings
  logger.debug("++++++++++> Sorting module, greetings method")
  logger.info("++++++++++> Sorting module, greetings method")
end

def merge(left, right)
  result = Array.new
  while((left.length > 0) && (right.length > 0)) do
    if(left.first.pts <= right.first.pts) then
      result << left.first
      left.shift
    else
      result << right.first
      right.shift
    end
  end  #while

  # if leftovers, when left.length > or < right.length, just append to results
  if(left.length > 0) then
    result.concat(left)
  else
    result.concat(right)
  end
  return result
end

def mergesort_objects(myarray)
  left = Array.new
  right = Array.new
  result = Array.new

  midint = 0
  
  if myarray.length <= 1 then
    return myarray
  else
    midint = myarray.length / 2
    for x in 0...midint do
      left << myarray[x]
    end
    for x in midint...myarray.length do
      right << myarray[x]
    end
    left = mergesort_objects(left)
    right = mergesort_objects(right)
    result = merge(left, right)
    return result
  end
end

def quicksort(array)
  lesser = Array.new
  greater = Array.new

  if array.length <= 1
    #puts " ==> one or fewer.  do nothing"
    return array
  end

  pivot = Array.new
  pivot << array[0]

  for i in 1...array.length
    if array[i].pts <= pivot[0].pts then
      lesser << array[i]
    else
      greater << array[i]
    end
  end
  #return lesser.concat(  pivot.concat(greater)  )
  return quicksort(lesser).concat(  pivot.concat(quicksort(greater))  )
end

def find_max(first, *rest)
  max = first
  rest.each { |x| max = x if x > max }
  logger.info("=====> Module: Sorting.rb : find_max returns #{max}")
  max
end

def countsort(array)
  myarray = array
  sortedarray = Array.new(myarray.length, 0)

  ptsarray = myarray.map(&:pts)
  #maxNumber = myarray.max
  maxNumber = find_max(*ptsarray)
  maxNumber += 1
  logger.info("=====> Sorting.countsort 1")
  # init counting array; fill [0] dummy 0

  logger.info("=====> Sorting.countsort 2")
  carray = Array.new(maxNumber, 0)
  logger.info("=====> Sorting.countsort 3")
  ccarray = Array.new(maxNumber, 0)

  logger.info("=====> Sorting.countsort 4")
  # count all the digits
  for i in 0...myarray.length
    # just incrementing by one here.
    carray[myarray[i].pts] = carray[myarray[i].pts] + 1 
  end
  logger.info("=====> Sorting.countsort 5")
  
  # sum count array; running total
  ccarray[0] = carray[0]
  for i in 1...carray.length
    ccarray[i] = ccarray[i-1] + carray[i]
  end
  logger.info("=====> Sorting.countsort 6")

  (myarray.length-1).downto(0) { |i|   #countsdown myarray index.  eg: 5 to 0 here
    sortedarray[ccarray[myarray[i].pts]-1] = myarray[i]
    ccarray[myarray[i].pts] = ccarray[myarray[i].pts] - 1 
  }
  logger.info("=====> Sorting.countsort 7")
  return sortedarray
end


end # module Sorting
