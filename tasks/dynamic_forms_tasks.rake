namespace :db do
  namespace :migrate do
    desc "Populating Database"
    task :dynamic_forms => :environment do 
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("vendor/plugins/dynamic_forms/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end
end
