DATA = <<-YML
settings:
  play_nice_timeout: 1
  max_scrapes: 500

seed_urls:
  - https://en.wikipedia.org/wiki/NASA

keywords:
  - nasa^10
  - space^1
  - apollo^1
  - gemini^1
  - mercury^1
  - spacecraft^1
  - space craft^1
  - soviet union^1
  - roscosmos^1
  - star city^1
  - space shuttle^1
  - international space station^1
  - iss^1
  - soyuz^1
  - cape canaveral^1
  - earth^1
  - galaxy^1
  - universe^1
  - nebula^1
  - planet^1
  - moon^1
  - astronaut^1
  - cosmonaut^1
  - mars^1
  - venus^1
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
