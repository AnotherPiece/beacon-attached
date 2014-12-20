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
        "" if hex.blank?

        file_name = self.send("#{name}_file_name".to_sym)
        Qiniu::Auth.authorize_download_url("#{options[:qiniu_host]}/#{hex[0]}/#{hex[1]}/#{hex[2]}/#{hex}/#{qiniu_name(style)}.#{tail_fix(style, file_name)}?#{image_size(style)}")
      end

      define_method :image_size do |style|
        if style && options[:qiniu_style] && style.to_sym != :original
          "imageView2/1/" + options[:qiniu_style][style]
        else
          ""
        end
      end

      define_method :tail_fix do |style, file_name|
        if style && options[:qiniu_bit_style] && options[:qiniu_bit_style][style].present?
          'mp3'
        else
          file_name.split('.').last
        end
      end

      define_method :qiniu_name do |style|
        if style && options[:qiniu_bit_style] && options[:qiniu_bit_style][style].present?
          style.to_s
        else
          "original"
        end
      end

      define_method :gen_hex do
        Digest::MD5.hexdigest("#{self.class}:#{DateTime.now}:#{rand}")
      end
    end

  end

  if defined?(ActiveRecord)
    ActiveRecord::Base.extend ClassMethods
  end
end
