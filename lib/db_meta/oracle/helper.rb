module DbMeta
  module Oracle
    module Helper

      def block(title, size = 80)
        line = '-- ' + ('-' * (size-3))
        buffer = [line, "-- #{title}", line].join("\n")
      end

      def type_sequence(type)
        return TYPE_SEQUENCE[type] || 99
      end

      def write_buffer_to_file(buffer, file)
        buffer = buffer.join("\n") if buffer.is_a?(Array)
        File.open(file, 'w') do |output|
          output.write(buffer)
        end
      end

      def remove_folder(folder)
        FileUtils.rm_rf(folder)
      end

      def create_folder(folder)
        Dir.mkdir(folder)
      rescue
      end

    end
  end
end
