require 'sqlite3'
require 'sequel'

# Setup our SQL database for things
DB = Sequel.connect 'sqlite://db/app.sqlite3', loggers: [ $logger ]

Sequel::Model.db = DB

Sequel::Model.plugin :update_or_create
Sequel::Model.plugin :timestamps
