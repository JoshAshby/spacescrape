require 'pg'
require 'sequel'

# Setup our SQL database for things
DB = Sequel.connect 'postgres://localhost/spacescrape', user: 'polymer', loggers: [ Logger.new(SpaceScrape.root.join('logs', 'sql.log')) ]

Sequel::Model.db = DB

Sequel::Model.plugin :update_or_create
Sequel::Model.plugin :timestamps
