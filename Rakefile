require "sinatra/activerecord"
require 'sinatra/activerecord/rake'
require 'pathname'
require_relative Pathname('config')+'config'

# What gets run when no arguments are specified
task default: ['wordcabin:server']
task s: ['wordcabin:server']
task c: ['console']

# The simpler the better, right?
desc "Run the couple of tests there are. Write more if you're a hero!"
task :test do
  sh "ruby #{Config.lib+'tests'+'tests.rb'}"
end

# Stolen from https://github.com/rails/rails/blob/master/railties/lib/rails/tasks/misc.rake
desc "Generate a cryptographically secure secret key to use as a cookie session secret"
task :secret do
  require 'securerandom'
  puts SecureRandom.hex(64)
end

# https://gist.github.com/vast/381881
desc "Enter an interactive application console"
task :console, :environment do |t, args|
  ENV['RACK_ENV'] = args[:environment] || 'development'
  system "pry -I . -r #{Config.lib+'server'} " \
         "-e 'include Wordcabin; User.connection; ContentFragment.connection; system(\"clear\");'"
end

namespace :db do
  task :load_config do
    require_relative Config.lib+'server'
    include Wordcabin 
  end

  desc "Empty the database of all its data, except users (DANGEROUS, obviously!)"
  task prune: :load_config do
    ContentFragment.delete_all
    FileAttachment.delete_all
  end
end   

namespace :wordcabin do
  desc "Update to the latest version from git, performing all the necessary steps"
  task :update do
    # Not done inside of here so that the script can be run on its
    # own, i.e. via a cron job, etc. and not fail even when rake
    # would not work for some reason.
    system "script/update"
  end

  desc "Give an overview over the project's structure"
  task :show_dirtree do
    ignore_list = []
    File.open('.gitmodules').each do |line|
      if /path = / =~ line
        ignore_list << line.split('/').last.chomp
      end
    end
    system "tree -d -I 'data|#{ignore_list.join('|')}'"
  end

  desc "Start application server on configured port"
  task :server do
    # Boot Puma via Rack, keep reloading via rerun.
    # The latter won't work using backticks, only using system(), because it forks off.
    watchlist = %w{config lib locales views}.join(',')
    rackupcmd = "rackup -s puma -o #{Config.bind_address} -p #{Config.bind_port}"
    system "killall -q stream_server"
    system "rerun --dir #{watchlist} --clear '#{rackupcmd}'"
  end

	desc "Add new exercises in batch mode"
	task :add_exercises do
    require Config.lib+'server'
    include Wordcabin
    Exercise.connection
    old_id = 0
    sort_order = 0
		loop do
      if old_id == 0
        print "parent ID ('DONE' to end input): "
      else
        print "parent ID (ENTER to keep #{old_id}, 'DONE' to end input): "
      end
      id = STDIN.gets.chomp
      id = old_id if id == ''
      if id == old_id
        sort_order += 1
      else
        sort_order = 0
      end
      break if id.include? "DONE"

			print "name ('DONE' to end input): "
      name = STDIN.gets.chomp
			break if name.include? "DONE"
			
			print "html ('NEXT' for next item, precede with 'DONE' to end input): "
      html = STDIN.gets("NEXT\n").chomp
			break if html.include? "DONE"
			
			x = Exercise.new(
				type: Wordcabin::ExerciseTypes::Fake.to_s,
        content_fragment_id: id,
        sort_order: sort_order,
				name: name,
        html: html.gsub(/NEXT/, '')
			)
			
			x.save; puts "Saved #{x.id}"
      old_id = id
		end
	end
end
