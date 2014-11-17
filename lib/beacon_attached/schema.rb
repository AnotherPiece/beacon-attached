require 'active_support/deprecation'

module BeaconAttached
  module Schema
    COLUMNS = {
      file_name: :string,
      content_type: :string,
      file_size: :integer,
      updated_at: :datetime
      # hex: :string
    }

    # def self.include(base)
    #   ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Statements
    #   ActiveRecord::ConnectionAdapters::TableDefinition.send :include, TableDefinition
    #   ActiveRecord::ConnectionAdapters::Table.send :include, TableDefinition

    #   if defined? ActiveRecord::Migration::CommandRecorder
    #     ActiveRecord::Migration::CommandRecorder.send :include, CommandRecorder
    #   end
    # end

    module Statements
      def add_beacon_attachment(table_name, *attachment_names)
        raise ArgumentError, "Need file name" if attachment_names.empty?

        options = attachment_names.extract_options!

        attachment_names.each do |attachment_name|
          COLUMNS.each_pair do |column_name, column_type|
            column = "#{attachment_name}_#{column_name}"
            unless column_exists? table_name.to_sym, column.to_sym
              column_options = options.merge(options[column_name.to_sym] || {})
              add_column(table_name, column, column_type, column_options)
            end
          end
        end
      end

      def remove_beacon_attachment(table_name, *attachment_names)
        rasie ArgumentError, "Please specify attachment name in your remove_beacon_attachment call in your migration." if attachment_names.empty?

        options = attachment_names.extract_options!

        attachment_names.each do |attachment_name|
          COLUMNS.each_pair do |column_name, column_type|
            column = "#{attachment_name}_#{column_name}"
            column_options = options.merge(options[column_name.to_sym] || {})
            remove_column(table_name, column, column_type, column_options)
          end
        end
      end
    end

    module TableDefinition
      def beacon_attachment(*attachment_names)
        options = attachment_names.extract_options!
        attachment_names.each do |attachment_name, column_type|
          COLUMNS.each_pair do |column_name, column_type|
            column_options = options.merge(options[column_name.to_sym] || {})
            column("#{attachment_name}_#{column_name}", column_type, column_options)
          end
        end
      end
    end

    module CommandRecorder
      def add_beacon_attachment(*args)
        record(:add_beacon_attachment, args)
      end

      private

      def invert_add_beacon_attachment(args)
        [:remove_beacon_attachment, args]
      end
    end

  end
end