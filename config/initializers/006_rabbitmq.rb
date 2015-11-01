require 'sneakers'

Sneakers.configure **SpaceScrape.config_for(:rabbitmq).symbolize_keys
Sneakers.logger = SpaceScrape.logger
