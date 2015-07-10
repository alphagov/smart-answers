if ENV['LOG_PARTIAL_SOURCE']
  module ActionView
    class LogSubscriber
      def render_partial(event)
        info do
          message = " Rendered #{from_rails_root(event.payload[:identifier])}"
          message << " within #{from_rails_root(event.payload[:layout])}" if event.payload[:layout]
          message << " (#{event.duration.round(1)}ms)"
          message << " from #{caller.find { |line| line =~ /\.erb/}.to_s.split(':in').first.split('/lib').last}"
        end
      end
    end
  end
end
