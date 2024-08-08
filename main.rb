require './timer-thread'

timer = 5.times.per_second do |i|
  puts "#{i + 1} times"
end
sleep 1
timer.stop