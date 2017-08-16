require 'oci8'
require 'fileutils'

require_relative 'connection'
require_relative 'helper'
require_relative 'base'
require_relative 'objects'

Dir[File.dirname(__FILE__) + '/types/*.rb'].each {|file| require file }

module DbMeta
  module Oracle
    class Oracle < DbMeta::Abstract
      include Helper

      register_type(:oracle)

      def initialize(args={})
        super(args)

        Connection.instance.set(@username, @password, @instance, @worker)

        @objects = Objects.new
      end

      def fetch(args={})
        Objects.all.each do |object|
          @objects << object
        end

        # parallel fetching of object details
        @objects.fetch
      ensure
        Connection.instance.disconnect
      end

      def extract(args={})
        format = args[:format] || :sql

        # validate args
        raise "Format [#{format}] is not supported" unless EXTRACT_FORMATS.include?(format)

        remove_folder(@base_folder)
        create_folder(@base_folder)

        @objects.merge_synonyms
        @objects.merge_grants
        @objects.embed_indexes
        @objects.embed_constraints
        @objects.embed_triggers

        extract_summary
        extract_create_all(args)
        extract_drop_all(args)

        # extract all default objects
        @objects.default_each do |object|
          folder = File.join(@base_folder, "#{"%02d" % type_sequence(object.type)}_#{object.type}".downcase)
          create_folder(folder)

          filename = File.join(folder, "#{object.name.downcase}.#{format.to_s}")
          write_buffer_to_file(object.extract(args), filename)
        end

      end

      private

      def extract_summary
        Log.info("Summarizing...")

        buffer = [block("Summary of #{@username}"), nil]

        total = 0
        @objects.summary_each do |type, count|
          total += count
          buffer << "#{SUMMARY_COLUMN_FORMAT_NAME % type.upcase.to_s}#{"%5d" % count} #{"(#{@objects.summary_system_object[type]} system #{pluralize(@objects.summary_system_object[type], 'object')})" if @objects.summary_system_object[type] > 0}"
        end
        buffer << nil

        buffer << "#{SUMMARY_COLUMN_FORMAT_NAME % 'Total Objects'}#{"%5d" % total}"
        buffer << nil
        buffer << nil

        # invalid objects
        if @objects.invalids?
          buffer << 'Invalid/Disabled Objects'
          @objects.invalid_each do |type, objects|
            buffer << "#{SUMMARY_COLUMN_FORMAT_NAME % type.upcase.to_s}#{"%5d" % objects.size}"
            objects.each do |object|
              buffer << "#{SUMMARY_COLUMN_FORMAT_NAME_RIGHT % object.name}"
            end
            buffer << nil
          end
        else
          buffer << 'No invalid/disabled objects'
        end
        buffer << nil

        filename = File.join(@base_folder, "#{"%02d" % type_sequence('SUMMARY')}_summary.txt")
        write_buffer_to_file(buffer, filename)
      end

      def extract_create_all(args={})
        Log.info("Extracting create all script...")

        buffer = [block("#{@username} - CREATE ALL")]

        current_type = nil
        @objects.default_each do |object|
          if current_type != object.type
            buffer << nil;
            buffer << block(object.type, 40)
          end

          folder = "#{'%02d' % type_sequence(object.type)}_#{object.type.downcase}"
          file = "#{object.name.downcase}.sql"
          buffer << "@#{File.join(folder,file)}"
          current_type = object.type
        end
        buffer << nil

        filename = File.join(@base_folder,"#{'%02d' % type_sequence('CREATE')}_create_all.sql")
        write_buffer_to_file(buffer, filename)
      end

      def extract_drop_all(args={})
        Log.info("Extracting drop all script...")

        buffer = [block("#{@username} - DROP ALL")]

        current_type = nil
        @objects.reverse_default_each do |object|

          if current_type != object.type
            buffer << nil;
            buffer << block(object.type, 40)
          end

          buffer << object.ddl_drop
          current_type = object.type
        end
        buffer << nil

        filename = File.join(@base_folder,"#{'%02d' % type_sequence('DROP')}_drop_all.sql")
        write_buffer_to_file(buffer, filename)
      end

    end
  end
end
