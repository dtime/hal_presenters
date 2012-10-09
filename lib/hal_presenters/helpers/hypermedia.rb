module HalPresenters
  module Helpers
    module Hypermedia
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.instance_eval do
          include(InstanceMethods)
          include HalPresenters::Helpers::Present
          include HalPresenters::Helpers::Rels
          include HalPresenters::Helpers::Exposable
          include HalPresenters::Helpers::Embeddable
          include HalPresenters::Helpers::Rootify

          include HalPresenters::Helpers::Template
        end
      end
      module InstanceMethods
        def initialize(item, opts = {})
          @model = item
          @options = opts
        end
        def reset(item, opts = {})
          @model = item
          @options = opts
          self
        end
        def options
          @options
        end
        def model
          @model
        end
      end
      module ClassMethods
        def build_singleton(item, opts = {})
          if @singleton
            @singleton.reset(item, opts)
          else
            @singleton = self.new(item, opts)
          end
          @singleton
        end
        def present(presentation, item, opts = {})
          build_singleton(item, opts).call(presentation)
        end
      end
    end
  end
end
