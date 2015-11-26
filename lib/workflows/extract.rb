module Workflows
  class Extract < Base
    subscribe to: 'doc:load',      with: Load
    subscribe to: 'doc:loaded' ,   with: ExtractContent
    subscribe to: 'doc:extracted', with: StoreContent

    def process(webpage_id:)
      payload = OpenStruct.new webpage_id: webpage_id

      publish to: 'doc:load', data: payload
    end
  end
end
