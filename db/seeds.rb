DATA = <<-YML
settings:
  play_nice_timeout: 60
  play_nice_jitter_threshold: 60
  max_scrapes: 500

blacklist:
  - '%xxx%'
  - '%adult%'
  - '%porn%'
  - '%drugs%'
  - '%.google.com%'
  - '%facebook.com%'
  - '%wikipedia.org/w/index.php%'

keywords:
  - nasa^10
  - space
  - apollo
  - gemini
  - mercury
  - spacecraft
  - space craft
  - soviet union
  - roscosmos
  - star city
  - space shuttle
  - international space station
  - iss
  - soyuz
  - cape canaveral
  - earth
  - galaxy
  - universe
  - nebula
  - planet
  - moon
  - astronaut^5
  - cosmonaut
  - mars
  - venus

seed_urls:
  - https://en.wikipedia.org/wiki/NASA
YML

module Seeds
  module_function
  # Make sure that our database has the basic items that we need. Basically a
  # seed file...
  def load_seeds
    Blacklist.set_dataset :blacklists
    Keyword.set_dataset :keywords
    Setting.set_dataset :settings

    starter = YAML.load DATA

    # where should we start off looking for things?
    # seed_urls = starter['seed_urls'].map &:freeze

    # What qualifies the page as something we should look for?
    starter['keywords'].each do |keyword|
      tupil = keyword.split('^', 2)

      Keyword.update_or_create keyword: tupil[0] do |model|
        weight = tupil[1].to_i
        weight = 1 if weight == 0
        model.weight = weight
      end
    end

    # Couple of default settings, these should be updatable from the web
    # eventually to allow for quick fine tuning
    starter['settings'].each do |key, val|
      Setting.update_or_create name: key do |model|
        model.value = val
      end
    end

    # Finally, ensure we don't do wandering off into somewhere we don't want to
    # be
    starter['blacklist'].each do |pattern|
      Blacklist.update_or_create pattern: pattern do |model|
        model.reason = "Don't want to wander here"
      end
    end
  end
end
