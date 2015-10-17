DATA = <<-YML
settings:
  play_nice_timeout: 60
  max_scrapes: 500
  jitter_threshold: 60

seed_urls:
  - https://en.wikipedia.org/wiki/NASA

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
YML

# Make sure that our database has the basic items that we need. Basically a
# seed file...
def load_seeds
  starter = YAML.load DATA

  # where should we start off looking for things?
  # seed_urls = starter['seed_urls'].map &:freeze

  # What qualifies the page as something we should look for?
  starter['keywords'].each do |keyword|
    tupil = keyword.split('^', 2)

    Keyword.find_or_create keyword: tupil[0] do |model|
      weight = tupil[1].to_i
      weight = 1 if weight == 0
      model.weight = weight
    end
  end

  starter['settings'].each do |key, val|
    Setting.find_or_create name: key do |model|
      model.value = val
    end
  end
end
