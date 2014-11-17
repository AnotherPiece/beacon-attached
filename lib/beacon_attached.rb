require "beacon_attached/version"
require "beacon_attached/engine"
require "beacon_attached/schema.rb"

module BeaconAttached

  ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, BeaconAttached::Schema::Statements
  ActiveRecord::ConnectionAdapters::TableDefinition.send :include, BeaconAttached::Schema::TableDefinition
  ActiveRecord::ConnectionAdapters::Table.send :include, BeaconAttached::Schema::TableDefinition

  if defined? ActiveRecord::Migration::CommandRecorder
    ActiveRecord::Migration::CommandRecorder.send :include, BeaconAttached::Schema::CommandRecorder
  end

  extend ActiveSupport::Concern
  ActiveRecord::Base.send :include, BeaconAttached::Schema

  module ClassMethods
    def has_beacon_attachment(name, options = {})
      define_method "#{name}_url".to_sym do |style = options[:default_style]|
        file_name = self.send("#{name}_file_name".to_sym)
        Qiniu::Auth.authorize_download_url("#{options[:qiniu_host]}/#{hex[0]}/#{hex[1]}/#{hex[2]}/#{hex}/original.#{file_name.split('.').last}?#{image_size(style)}")
      end

      define_method :image_size do |style|
        if style && options[:qiniu_style] && style.to_sym != :original
          "imageView2/1/" + options[:qiniu_style][style]
        else
          ""
        end
      end
    end

    def gen_hex
      Digest::MD5.hexdigest("#{self}:#{rand}:#{DateTime.now}")
    end
  end

  if defined?(ActiveRecord)
    ActiveRecord::Base.extend ClassMethods
  end
end
