module DbMeta
  module Oracle
    class Grant < Base
      register_type('GRANT')

      attr_reader :grantee, :owner, :table_name, :grantor, :privilege, :grantable

      def initialize(args={})
        super(args)
        @extract_type = :merged
      end

      def fetch(args={})
        # definition is comma seperated in the name to prevent re-fetching table for every grant
        @grantee, @owner, @table_name, @grantor, @privilege, @grantable = @name.split(',')
      end

      def extract(args={})
        buffer = ""
        buffer << ( '%-30s' % "-- granted via #{@grantor}: ") if external_grant?
        buffer << "GRANT #{"%-18s" % @privilege} ON #{"%-32s" % @table_name} TO #{@grantee}"
        buffer << " WITH GRANT OPTION" if @grantable == 'YES'
        buffer << ";"
        buffer
      end

      def ddl_drop
        buffer = ""

        buffer << ( '%-30s' % "-- granted via #{@grantor}: ") if external_grant?
        buffer << "REVOKE #{"%-18s" % @privilege} ON #{"%-32s" % @table_name} FROM #{@grantee};"
        buffer
      end

      def external_grant?
        @grantee == Connection.instance.username.upcase
      end

      def sort_value
        return ["2", @grantor, @privilege, @table_name] if external_grant?
        return ["1", @grantee, @privilege, @table_name]
      end

    end
  end
end
