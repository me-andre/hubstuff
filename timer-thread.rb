class Timer
  def initialize interval, &block
    @interval = interval
    @block = block
    @stopped = false
    @mutex = Mutex.new
  end

  def start
    start_time = Process.clock_gettime Process::CLOCK_MONOTONIC, :float_second
    Thread.new do
      times = 0
      loop do
        break if @stopped
        @mutex.synchronize do
          @block.call times
        end
        times += 1
        time_now = Process.clock_gettime Process::CLOCK_MONOTONIC, :float_second
        next_execution_time = start_time + times * @interval
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
