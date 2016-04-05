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
    raw_classifier = Marshal.dump @classifier
    SpaceScrape.cache.set "naive-bayes:#{ @name }", raw_classifier

    raw_trained_docs = Marshal.dump @trained_docs
    SpaceScrape.cache.set "naive-bayes:#{ @name }:documents", raw_trained_docs
  end

  def classifier
    return @classifier if @classifier

    if SpaceScrape.cache.cached? "naive-bayes:#{ @name }"
      raw = SpaceScrape.cache.get "naive-bayes:#{ @name }"
      @classifier = Marshal.load raw
    else
      @classifier = ClassifierReborn::Bayes.new auto_categorize: true
      save!
    end

    @classifier
  end

  def trained_docs
    return @trained_docs if @trained_docs

    if SpaceScrape.cache.cached? "naive-bayes:#{ name }:documents"
      raw = SpaceScrape.cache.get "naive-bayes:#{ name }:documents"
      @trained_docs = Marhsal.load raw
    else
      @trained_docs = []
      save!
    end

    @trained_docs
  end
end
