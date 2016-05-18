module DbMeta
  module Oracle
    class Table < Base
      register_type(:table)


      def extract(args={})
        buffer = []
        buffer << "create table #{@name}"
        buffer << nil

        buffer.join("\n")
      end

    end
  end
end
