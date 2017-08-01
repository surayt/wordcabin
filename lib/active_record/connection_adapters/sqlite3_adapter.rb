module Wordcabin
  # Adapted from http://joeyates.info/2010/01/31/regular-expressions-in-sqlite/
  # Implements SQLite's REGEXP function in Ruby (like the commandline client's 'pcre' extension)
  class ActiveRecord::ConnectionAdapters::SQLite3Adapter < ActiveRecord::ConnectionAdapters::AbstractAdapter 
    include SemanticLogger::Loggable
    
    def initialize(connection, logger, connection_options, config) # (db, logger, config)
      # Verbatim from https://github.com/rails/rails/blob/e2e63770f59ce4585944447ee237ec
      # 722761e77d/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb
      super(connection, logger, config)
      @active     = nil
      @statements = StatementPool.new(self.class.type_cast_config_to_integer(config[:statement_limit]))
      configure_connection
      # Unchanged from source
      connection.create_function('regexp', 2) do |func, pattern, expression|
        regexp = Regexp.new(pattern.to_s, Regexp::IGNORECASE)
        if expression.to_s.match(regexp)
          func.result = 1
        else
          func.result = 0
        end
      end
      # https://gist.github.com/datenimperator/7602535
      ['PRAGMA main.page_size=4096;',
       'PRAGMA main.cache_size=10000;',
       # 'PRAGMA main.locking_mode=EXCLUSIVE;',
       'PRAGMA main.synchronous=NORMAL;',
       'PRAGMA main.journal_mode=WAL;',
       'PRAGMA main.temp_store = MEMORY;'].each do |tweak|
        connection.execute tweak
      end
    end
  end
end
