require 'oci8'

require_relative 'connection'
require_relative 'base'
require_relative 'types/table'
require_relative 'types/package'
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
require_relative 'types/database_link'

require_relative 'types/column'
require_relative 'types/comment'

module DbMeta
  module Oracle
    class Oracle < DbMeta::Abstract
      register_type(:oracle)


      def initialize(args={})
        super(args)
        Connection.instance.set(@username, @password, @instance, @worker)
      end

      def fetch(args={})
        items = get_all_items_sorted(args)

        # instantize objects
        items.each do |item|
          object = Base.from_type(item)
          @types << object.type
          @invalid_objects[object.type] << object if object.status == :invalid
          @objects << object
        end
        @types.uniq!

        # fetch details in parallel
        worker_queue = Queue.new
        @objects.map{ |object| worker_queue.push(object) }

        # start as many threads as max physical connections
        worker = (1..Connection.instance.worker).map do
          Thread.new do
            begin
              while object = worker_queue.pop(true)
                Log.info(" - #{object.type} - #{object.name}")
                object.fetch
              end
            rescue ThreadError
            end
          end
        end
        worker.map(&:join)

      ensure
        Connection.instance.disconnect
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

        extract_create_all(args)
        extract_drop_all(args)
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

      def get_all_items_sorted(args)
        # get all objects with name, type, status
        items = []
        types = []
        connection = Connection.instance.get
        cursor = connection.exec('select * from user_objects order by object_type, object_name')
        cursor.fetch_hash do |item|
          next if item['OBJECT_TYPE'] == 'PACKAGE BODY'
          items << item
          types << item['OBJECT_TYPE']
        end
        cursor.close

        # sort items
        items = items.sort_by{ |i| [ type_sequence(i['OBJECT_TYPE']), i['OBJECT_NAME']]}

        Log.info("Objects: #{items.size}, Object Types: #{types.uniq.size}")

        items
      ensure
        connection.logoff # closes logical connection
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
          buffer << "#{SUMMARY_COLUMN_FORMAT_NAME % type.upcase.to_s}#{"%5d" % count}"
        end
        buffer << nil
        buffer << nil

        # invalid objects
        if @invalid_objects.size == 0
          buffer << 'No invalid objects'
        else
          buffer << 'Invalid Objects'
          @invalid_objects.each_pair do |type, objects|
            buffer << "#{SUMMARY_COLUMN_FORMAT_NAME % type.upcase.to_s}#{"%5d" % objects.size}"
            objects.each do |object|
              buffer << "#{SUMMARY_COLUMN_FORMAT_NAME_RIGHT % object.name}"
            end
            buffer << nil
          end
        end
        buffer << nil

        File.open(File.join(@base_folder, "#{"%02d" % type_sequence('SUMMARY')}_summary.txt"), 'w') do |output|
          output.write(buffer.join("\n"))
        end
      end

      def type_sequence(type)
        return TYPE_SEQUENCE[type] || 99
      end

      def extract_create_all(args={})
        Log.info("Extracting create all script...")

        buffer = []
        buffer << '-- ' + ('-' * 80)
        buffer << "-- #{@username} - CREATE ALL"
        buffer << '-- ' + ('-' * 80)

        current_type = nil
        @objects.each do |object|
          buffer << nil if current_type != object.type
          folder = "#{'%02d' % type_sequence(object.type)}_#{object.type.downcase}"
          file = "#{object.name.downcase}.sql"
          buffer << "@#{File.join(folder,file)}"
          current_type = object.type
        end

        File.open(File.join(@base_folder,"#{'%02d' % type_sequence('CREATE')}_create_all.sql"), 'w') do |output|
          output.write(buffer.join("\n"))
        end
      end

      def extract_drop_all(args={})
        Log.info("Extracting drop all script...")

        buffer = []
        buffer << '-- ' + ('-' * 80)
        buffer << "-- #{@username} - DROP ALL"
        buffer << '-- ' + ('-' * 80)
        buffer << nil

        current_type = nil
        @objects.reverse_each do |object|
          buffer << nil if current_type != object.type
          buffer << "DROP #{object.type} #{object.name};"
          current_type = object.type
        end
        buffer << nil

        File.open(File.join(@base_folder,"#{'%02d' % type_sequence('DROP')}_drop_all.sql"), 'w') do |output|
          output.write(buffer.join("\n"))
        end
      end

    end
  end
end
