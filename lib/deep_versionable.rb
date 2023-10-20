# frozen_string_literal: true

require 'active_support/concern'
require 'active_record'

module DeepVersionable
  extend ActiveSupport::Concern

  module Initializer
    def as_deep_versionable
      send :include, DeepVersionable
    end
  end

  included do
    class_attribute :_deep_versionable_relations
    has_many :versions, as: :versionable, dependent: :destroy
  end

  module ClassMethods
    def deep_versionable(include: {})
      declare_versionable_class(self.name)
      self._deep_versionable_relations = parse_include(include, self)
    end

    private

    def declare_versionable_class(name)
      return if Object.const_defined?("DeepVersionable::Version::#{name}")

      dynamic_class = Class.new(OpenStruct) do
        include ActiveModel::Serialization

        def initialize(object = nil)
          super(object)
        end
      end

      Version.const_set(name, dynamic_class)

      declare_versionable_serializer(name) if Rails.configuration.deep_versionable_declare_serializers
    end

    def declare_versionable_serializer(name)
      return if Object.const_defined?("DeepVersionable::Version::#{name}Serializer")

      serializer = "#{name}Serializer".safe_constantize
      # TODO: Implement logger
      # Rails.logger.debug("Serializer #{name}Serializer not found. Using ApplicationSerializer for Version::#{name}") unless serializer

      dynamic_class = Class.new(serializer || ApplicationSerializer) do
        type name.underscore.pluralize
      end

      Version.const_set("#{name}Serializer", dynamic_class)
    end

    def parse_include(include, klass)
      parsed_include = { include: [] }

      include.each do |i|
        if i.is_a?(Hash)
          i.each do |k, v|
            declare_versionable_class(load_class(klass, k).name)
            parsed_include[:include] << { k => parse_include(v, load_class(klass, k)) }
          end
        else
          declare_versionable_class(load_class(klass, i).name)
          parsed_include[:include] << i
        end
      end

      parsed_include
    end

    def load_class(klass, key)
      association = klass.reflect_on_all_associations.detect { |e| e.name == key.to_sym }
      class_name = association.options[:class_name] ? association.options[:class_name].to_s : key.to_s.classify

      class_name.constantize
    end
  end

  def versionize!
    object = to_json(self.class._deep_versionable_relations)

    versions.create!(version: versions.count + 1, object: object)
  end
end

# rubocop:disable Lint/SendWithMixinArgument
ActiveRecord::Base.send(:extend, DeepVersionable::Initializer)
# rubocop:enable Lint/SendWithMixinArgument
