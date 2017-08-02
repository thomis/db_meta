require 'oci8'

require_relative 'connection'
require_relative 'base'
require_relative 'types/table'
require_relative 'types/package'
require_relative 'types/package_body'
require_relative 'types/trigger'
require_relative 'types/type'
require_relative 'types/column'
require_relative 'types/function'
require_relative 'types/index'
require_relative 'types/synonym'
require_relative 'types/procedure'
require_relative 'types/sequence'
require_relative 'types/lob'
require_relative 'types/materialized_view'
require_relative 'types/view'

require_relative 'types/column'

module DbMeta
  module Oracle
    class Oracle < DbMeta::Abstract
      register_type(:oracle)


      def initialize(args={})
        super(args)

        Connection.instance.set(@username, @password, @instance)
      end

      def fetch(args={})


        cursor = Connection.instance.get.exec('select * from user_objects order by object_type, object_name')
        cursor.fetch_hash do |row|
          type = row['OBJECT_TYPE'].downcase.to_sym
          @types << type
          object = Base.from_type(type, row.merge(type: type))

          Log.info(" - #{object.type} - #{object.name}")

          @invalid_objects[type] << object if object.status == :invalid
          @objects << object
        end
        cursor.close
        @types.uniq!


        Log.info("Objects: #{@objects.size}, Object Types: #{@types.size}")
      end

      def extract(args={})
        format = args[:format] || :sql

        # validate args
        raise "Format [#{format}] is not supported" unless EXTRACT_FORMATS.include?(format)

        make_folders
        summary

        # extract every object
        @objects.each do |object|
          file_name = File.join(@base_folder, "#{"%02d" % type_sequence(object.type)}_#{object.type.to_s}", "#{object.name.downcase}.#{format.to_s}")
          File.open(file_name, 'w') do |output|
            output.write(object.extract(args))
          end
        end
      end

      private

      def make_folders
        folders = [@base_folder]

        @types.each do |type|
          folders << File.join(@base_folder,"#{"%02d" % type_sequence(type)}_#{type.to_s}")
        end

        folders.each do |folder|
          begin
            Dir.mkdir(folder)
          rescue => e
          end
        end

      end

      def summary
        Log.info("Summarizing...")
        types = Hash.new(0)

        @objects.each do |o|
          types[o.type] += 1
        end

        buffer = []
        buffer << '-- ' + ('-' * 80)
        buffer << "-- Summary of #{@username}"
        buffer << '-- ' + ('-' * 80)
        buffer << nil
        buffer << "#{SUMMARY_COLUMN_FORMAT_NAME % 'Total Objects'}#{"%5s" % @objects.size.to_s}"
        buffer << nil
        types.each_pair do |type, count|
          buffer << "#{SUMMARY_COLUMN_FORMAT_NAME % type.to_s}#{"%5d" % count}"
        end
        buffer << nil
        buffer << nil

        # invalid objects
        if @invalid_objects.size == 0
          buffer << 'No invalid objects'
        else
          buffer << 'Invalid Objects'
          @invalid_objects.each_pair do |type, objects|
            buffer << "#{SUMMARY_COLUMN_FORMAT_NAME % type.to_s}#{"%5d" % objects.size}"
            objects.each do |object|
              buffer << "#{SUMMARY_COLUMN_FORMAT_NAME_RIGHT % object.name}"
            end
            buffer << nil
          end
        end

        File.open(File.join(@base_folder, "#{"%02d" % type_sequence(:summary)}_summary.txt"), 'w') do |output|
          output.write(buffer.join("\n"))
        end
      end

      def type_sequence(type)
        return TYPE_SEQUENCE[type] || 99
      end

    end
  end
end
