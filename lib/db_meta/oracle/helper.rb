module DbMeta
  module Oracle
    module Helper
      def block(title, size = 80)
        line = "-- " + ("-" * (size - 3))
        [line, "-- #{title}", line].join("\n")
      end

      def type_sequence(type)
        TYPE_SEQUENCE[type] || 99
      end

      def write_buffer_to_file(buffer, file)
        buffer = buffer.join("\n") if buffer.is_a?(Array)
        File.write(file.downcase.tr(" ", "_"), buffer)
      end

      def remove_folder(folder)
        FileUtils.rm_rf(folder)
      end

      def create_folder(folder)
        Dir.mkdir(folder.downcase.tr(" ", "_"))
      rescue
      end

      def pluralize(n, singular, plural = nil)
        return singular if n == 1
        (plural || (singular + "s"))
      end
    end
  end
end
