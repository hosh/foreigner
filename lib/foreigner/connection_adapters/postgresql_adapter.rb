module Foreigner
  module ConnectionAdapters
    module PostgreSQLAdapter
      include Foreigner::Semantics::Sql2003

      
      def foreign_keys(table_name)
        fk_info = select_all %{
          SELECT tc.constraint_name as name,
            ccu.table_name as to_table,
            ccu.column_name as primary_key,
            kcu.column_name as column,
            rc.delete_rule as dependency
          FROM information_schema.table_constraints tc
          JOIN information_schema.key_column_usage kcu
            USING (constraint_catalog, constraint_schema, constraint_name)
          JOIN information_schema.referential_constraints rc
            USING (constraint_catalog, constraint_schema, constraint_name)
          JOIN information_schema.constraint_column_usage ccu
            USING (constraint_catalog, constraint_schema, constraint_name)
          WHERE tc.constraint_type = 'FOREIGN KEY'
            AND tc.constraint_catalog = '#{@config[:database]}'
            AND tc.table_name = '#{table_name}'
        }
        
        fk_info.map do |row|
          options = {:column => row['column'], :name => row['name'], :primary_key => row['primary_key']}

          options[:dependent] = case row['dependency']
            when 'CASCADE'  then :delete
            when 'SET NULL' then :nullify
            end

          ForeignKeyDefinition.new(table_name.to_s, row['to_table'], options)
        end
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    PostgreSQLAdapter.class_eval do
      include Foreigner::ConnectionAdapters::PostgreSQLAdapter
    end
  end
end
