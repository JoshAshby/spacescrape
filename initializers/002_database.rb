require 'pg'
require 'sequel'

# Setup our SQL database for things
DB = Sequel.connect **SpaceScrape.config_for(:database).symbolize_keys, loggers: [ Logger.new(SpaceScrape.root.join('logs', 'sql.log')) ]
DB.extension :pagination

Sequel::Model.db = DB

Sequel::Model.plugin :update_or_create
Sequel::Model.plugin :timestamps
