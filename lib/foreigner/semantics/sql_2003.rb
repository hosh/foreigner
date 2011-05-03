module Foreigner
  module Semantics
    module Sql2003
      def supports_foreign_keys?
        true
      end

      def foreign_key_definition(to_table, options = {})
        column  = options[:column] || "#{to_table.to_s.singularize}_id"
        dependency = sql_for_dependency(options[:dependent])

        sql = "FOREIGN KEY (#{quote_column_name(column)}) REFERENCES #{quote_table_name(to_table)}(id)"
        sql << " #{dependency}" unless dependency.blank?
        sql
      end

      def add_foreign_key(from_table, to_table, options = {})
        column  = options[:column] || column_name(to_table)
        foreign_key_name = foreign_key_name(from_table, column, options)
        primary_key = options[:primary_key] || "id"
        reference = sql_for_reference(to_table, primary_key)
        dependency = sql_for_dependency(options[:dependent])

        execute(sql_for_add_foreign_key(from_table, foreign_key_name, column, reference, dependency))
      end

      def remove_foreign_key(table, options)
        # If the second argument is table name (String/Symbol) then convert that to the
        # to the full options hash
        options = { :column => column_name(options) } if String === options || Symbol === options
        execute(sql_for_remove_foreign_key(table, foreign_key_name(table, options[:column], options)))
      end

      private
      
      def foreign_key_name(table, column, options = {})
        return options[:name] if options[:name]
        "fk_#{table}_#{column}"
      end

      def column_name(column)
        "#{column.to_s.singularize}_id"
      end
      
      # Generates SQL and returns it. 
      def sql_for_add_foreign_key(from_table, foreign_key_name, column, reference, dependent = nil)
        sql = [
          "ALTER TABLE #{quote_table_name(from_table)}",
          "ADD CONSTRAINT #{quote_column_name(foreign_key_name)}",
          "FOREIGN KEY (#{quote_column_name(column)})",
          "REFERENCES #{reference}"
        ]

        sql << "#{dependent}" unless dependent.blank?
        sql.join(' ')
      end

      def sql_for_remove_foreign_key(table, foreign_key_name)
        "ALTER TABLE #{quote_table_name(table)} DROP CONSTRAINT #{quote_column_name(foreign_key_name)}"
      end

      def sql_for_reference(to_table, primary_key)
        "#{quote_table_name(ActiveRecord::Migrator.proper_table_name(to_table))}(#{primary_key})"
      end


      def sql_for_dependency(dependency)
        case dependency
          when :nullify then 'ON DELETE SET NULL'
          when :delete  then 'ON DELETE CASCADE'
          else ''
        end
      end

    end
  end
end

