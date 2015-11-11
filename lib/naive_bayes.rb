require 'classifier-reborn'

# Helper to wrap up the classifier and tie it in with the cache system to
# ensure its saved
class NaiveBayes
  def initialize(name:)
    @name = name
  end

  def add(topic:)
    classifier.add_category topic
  end

  def knows?(topic:)
    classifier.categories.include? topic
  end

  def train(topic:, doc:)
    classifier.train topic, doc
  end

  def untrain(topic:, doc:)
    classifier.untrain topic, doc
  end

  def classify(doc:)
    fail StandardError, "No topics defined" unless classifier.categories.any?
    classifier.classify_with_score doc
  end

  def save!
    raw = Marshal.dump @classifier
    SpaceScrape.cache.set @name, raw
  end

  def classifier
    return @classifier if @classifier

    if SpaceScrape.cache.cached? @name
      raw = SpaceScrape.cache.get @name
      @classifier = Marshal.load raw
    else
      @classifier = ClassifierReborn::Bayes.new
      save!
    end

    @classifier
  end
end
