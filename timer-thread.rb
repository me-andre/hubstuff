class Timer
  def initialize interval, &block
    @interval = interval
    @block = block
    @stopped = false
  end

  def start
    start_time = Process.clock_gettime Process::CLOCK_MONOTONIC, :float_second
    Thread.new do
      times = 0
      loop do
        break if @stopped
        @block.call times
        times += 1
        time_now = Process.clock_gettime Process::CLOCK_MONOTONIC, :float_second
        next_execution_time = start_time + (times + 1) * @interval
        sleep_time = next_execution_time - time_now
        sleep_time = 0 if sleep_time < 0
        sleep sleep_time
      end
    end
  end

  def stop
    @stopped = true
  end
end

class ::Enumerator
  def per_second &block
    interval = 1.0 / count
    timer = Timer.new interval, &block
    timer.start
    timer
  end
end

timer = 5.times.per_second do |i|
  puts "#{i + 1} times"
end
sleep 1
timer.stop
