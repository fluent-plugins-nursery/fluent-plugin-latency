module Fluent
  class LatencyOutput < Output
    Plugin.register_output('latency', self)

    # To support log_level option implemented by Fluentd v0.10.43
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    config_param :tag, :string, :default => 'latency'
    config_param :interval, :time, :default => 60

    attr_reader :latency # for test

    def initialize
      super
      @latency = []
    end

    def configure(conf)
      super
    end

    def emit(tag, es, chain)
      current = Time.now.to_f
      es.each do |time, record|
        @latency << (current - time)
      end
      chain.next
    end

    def start
      super
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      super
      @thread.terminate
      @thread.join
    end

    def run
      @last_checked ||= Engine.now
      while (sleep 0.5)
        now = Engine.now
        if now - @last_checked >= @interval
          flush_emit
          @last_checked = now
        end
      end
    end

    def flush_emit
      latency, @latency = @latency, []
      num = latency.size
      max = num == 0 ? 0 : latency.max
      avg = num == 0 ? 0 : latency.map(&:to_f).inject(:+) / num.to_f
      message = {"max" => max, "avg" => avg, "num" => num}
      Engine.emit(@tag, Engine.now, message)
    end
  end
end
