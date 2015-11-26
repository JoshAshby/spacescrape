module SpaceScrape
  module_function
  def pub_sub
    @pub_sub ||= PubSub.new
  end
end
