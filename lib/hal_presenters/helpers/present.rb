module HalPresenters
  module Helpers
    module Present
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
      module ClassMethods
        def presentation(name, *filters)
          presentations[name] = filters
        end
        def presentations
          @presentations ||= {}
          @presentations
        end
        def default_after_filter(filter)
          default_after_filters << filter
        end
        def default_after_filters
          @default_after_filters ||= []
          @default_after_filters
        end
        def default_filter(filter)
          default_filters << filter
        end
        def default_filters
          @default_filters ||= []
          @default_filters
        end
      end
      module InstanceMethods
        def call(presentation, opts = {})
          presentation = presentation.to_sym
          unless self.class.presentations.keys.include?(presentation)
            raise "Presentation must be defined"
          end
          unless self.respond_to?(presentation)
            raise "Present relies on a presentation method (#{presentation})"
          end
          @options = @options.merge(opts)
          presented = self.send(presentation)
          self.class.default_filters.each do |filter|
            presented = self.send(filter.to_sym, presented, presentation)
          end
          self.class.presentations[presentation].each do |filter|
            presented = self.send(filter.to_sym, presented, presentation)
          end
          self.class.default_after_filters.each do |filter|
            presented = self.send(filter.to_sym, presented, presentation)
          end
          presented
        end
        alias :present :call
      end
    end
  end
end
