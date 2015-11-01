DATA = <<-YML
settings:
  play_nice_timeout: 60
  play_nice_jitter_threshold: 60

topics:
  general_nasa:
    settings:
      max_scrapes: 500

    blacklist:
      - '(.*)xxx(.*)'
      - '(.*)adult(.*)'
      - '(.*)porn(.*)'
      - '(.*)drugs(.*)'
      - '(.*)google.com(.*)'
      - '(.*)facebook.com(.*)'
      - '(.*)instagram.com(.*)'
      - '(.*)twitter.com(.*)'
      - '(.*)tinyurl.com(.*)'
      - '(.*)linkedin.com(.*)'
      - '(.*)youtube.com(.*)'
      - '(.*)pintrest.com(.*)'
      - '(.*)howstuffworks.com(.*)'
      - '(.*)adobe.com(.*)'
      - '(.*)toms(.*)'
      - '(.*)t.co(.*)'
      - '(.*)wikipedia.org/w/index.php(.*)'

    bootstrap_keywords:
      - nasa
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
      - astronaut
      - cosmonaut
      - mars
      - venus

training:
  - url: https://en.wikipedia.org/wiki/NASA
    topics:
      - general_nasa
YML

module Seeds
  module_function
  # Make sure that our database has the basic items that we need. Basically a
  # seed file...
  def load_seeds
    Topic.set_dataset :topics
    Blacklist.set_dataset :blacklists
    Keyword.set_dataset :keywords
    Setting.set_dataset :settings

    starter = YAML.load DATA

    # Couple of default settings, these should be updatable from the web
    # eventually to allow for quick fine tuning
    starter['settings'].each do |key, val|
      Setting.update_or_create name: key do |model|
        model.value = val
      end
    end

    starter['topics'].each do |key, val|
      topic = Topic.create name: key

      # Couple of default settings, these should be updatable from the web
      # eventually to allow for quick fine tuning
      val['settings'].each do |name, value|
        Setting.update_or_create name: name, topic: topic do |model|
          model.value = value
        end
      end

      # What qualifies the page as something we should look for?
      val['bootstrap_keywords'].each do |keyword|
        tupil = keyword.split('^', 2)

        Keyword.update_or_create keyword: tupil[0], topic: topic do |model|
          weight = tupil[1].to_i
          weight = 1 if weight == 0
          model.weight = weight
        end
      end

      # Finally, ensure we don't do wandering off into somewhere we don't want to
      # be
      val['blacklist'].each do |pattern|
        Blacklist.update_or_create pattern: pattern, topic: topic do |model|
          model.reason = "Don't want to wander here"
        end
      end

    end
  end
end
