module Workers
  class AnalyzeWorker
    include Sneakers::Worker
    from_queue 'analyze'

    def work msg
      data = JSON.parse msg
      analyzer = Workflows::Analyze.new

      analyzer.subscribe to: 'doc:fetched' do |bus, env|
        env[:model].links.each do |link|
          self.class.enqueue({ url: link }.to_json)
        end
      end

      analyzer.process url: data['url']

      ack!
    end
  end
end
