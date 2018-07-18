require 'rubygems'
require 'yaml'
require 'active_record'
require 'rails/railtie'
require 'yaml_db/rake_tasks'
require 'yaml_db/version'
require 'yaml_db/serialization_helper'

module YamlDb
  module Helper
    def self.loader
      Load
    end

    def self.dumper
      Dump
    end

    def self.extension
      "yml"
    end
  end


  module Utils
    def self.chunk_records(records)
      yaml = [ records ].to_yaml
      yaml.sub!(/---\s\n|---\n/, '')
      yaml.sub!('- - -', '  - -')
      yaml
    end

  end

  class Dump < SerializationHelper::Dump

    def self.dump_table_columns(io, table)
      io.write("\n")
      io.write({ table => { 'columns' => table_column_names(table) } }.to_yaml)
    end

    def self.dump_table_records(io, table)
      table_record_header(io)

      column_names = table_column_names(table)

      each_table_page(table) do |records|
        rows = SerializationHelper::Utils.unhash_records(records.to_a, column_names)
        io.write(Utils.chunk_records(rows))
      end
    end

    def self.table_record_header(io)
      io.write("  records: \n")
    end

  end

  class Load < SerializationHelper::Load
    def self.load_documents(io, truncate = true)
        excludes = ( ENV["exclude"] || "" ).split(",")
        includes = ( ENV["include"] || "" ).split(",")

        YAML.load_stream(io) do |ydoc|
          all_tables=ydoc.keys
          tables_for_run=(includes.any? ? (all_tables && includes) : (all_tables - excludes))
          # p tables_for_run
          # exit

          tables_for_run.each do |table_name|
            p "Table : #{table_name}"
            next if ydoc[table_name].nil?
            load_table(table_name, ydoc[table_name], false)
          end
        end
    end
  end

  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../tasks/yaml_db_tasks.rake',
__FILE__)
    end
  end

end
