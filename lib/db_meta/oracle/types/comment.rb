module DbMeta
  module Oracle
    class Comment
      attr_reader :text

      def self.find(args={})

        connection = Connection.instance.get
        cursor = connection.exec("select comments from user_tab_comments where table_type = '#{args[:type]}' and table_name = '#{args[:name]}'")
        while row = cursor.fetch()
          @text = row[0]
        end

      ensure
        connection.logoff
      end

    end
  end
end
