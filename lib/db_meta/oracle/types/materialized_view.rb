module DbMeta
  module Oracle
    class MaterializedView < Base
      register_type('MATERIALIZED VIEW')

      def extract(args={})
        buffer = [block(@name)]
        buffer << "CREATE OR REPLACE VIEW #{@name}"
        buffer << '('
      end

    end
  end
end
