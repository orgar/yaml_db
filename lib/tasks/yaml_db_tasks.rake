namespace :db do
  desc "Dump schema and data to db/schema.rb and db/data.yml"
  task(:dump => [ "db:schema:dump", "db:data:dump" ])

  desc "Load schema and data from db/schema.rb and db/data.yml"
  task(:load => [ "db:schema:load", "db:data:load" ])

  namespace :data do
    desc "Dump contents of database to db/data.extension (defaults to yaml)"
    task :dump => :environment do
      YamlDb::RakeTasks.data_dump_task
    end

    desc "Dump contents of database to curr_dir_name/tablename.extension (defaults to yaml)"
    task :dump_dir => :environment do
      YamlDb::RakeTasks.data_dump_dir_task
    end

    desc "Dump contents of given tables to db/tables/tablename.extension (defaults to yaml)"
    task :dump_tables_dir => :environment do
      tables = ENV['tables'].to_s.split(',').collect(&:strip).compact.uniq
      ENV['dir'] ||= 'tables'
      puts "Specify tables via # tables='table1,table2'" if tables.empty?
      YamlDb::RakeTasks.data_dump_tables_dir_task(tables)
    end

    desc "Load contents of db/data.extension (defaults to yaml) into database"
    task :load => :environment do
      YamlDb::RakeTasks.data_load_task
    end

    desc "Load contents of db/data_dir into database"
    task :load_dir  => :environment do
      YamlDb::RakeTasks.data_load_dir_task
    end

    desc "Load contents of given tables from db/data_dir (default dir is 'tables') into database"
    task :load_tables_dir  => :environment do
      tables = ENV['tables'].to_s.split(',').collect(&:strip).compact.uniq
      ENV['dir'] ||= 'tables'
      puts "Specify tables via # tables='table1,table2'" if tables.empty?
      YamlDb::RakeTasks.data_load_tables_dir_task(tables)
    end

  end
end
