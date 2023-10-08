# frozen_string_literal: true

module DeepVersionable
    class Version < ApplicationRecord
        belongs_to :versionable, polymorphic: true
      
        validates :version, :object, presence: true
        validates :version, uniqueness: { scope: %i[versionable_id versionable_type] }
      
        def reify
          rebuild_model(versionable_type, JSON.parse(object))
        end
      
        private
      
        def rebuild_model(klass, object)
          object.each do |k, v|
            next unless association_exists?(klass, k)
      
            case v
            when Hash
              object[k] = rebuild_model(load_class(klass, k), v)
            when Array
              object[k] = v.map do |i|
                if i.is_a?(Hash)
                  rebuild_model(load_class(klass, k), i)
                else
                  i
                end
              end
            end
          end
      
          instance = Version.const_get(klass).new(object)
          instance.freeze
          instance
        end
      
      def load_class(klass, key)
        association = klass.constantize.reflect_on_all_associations.detect { |e| e.name == key.to_sym }
        association.options[:class_name] ? association.options[:class_name].to_s : key.to_s.classify
      end
      
      def association_exists?(klass, key)
        klass.constantize.reflect_on_all_associations.detect { |e| e.name == key.to_sym }.present?
      end
    end
end