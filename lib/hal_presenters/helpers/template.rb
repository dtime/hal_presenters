module HalPresenters
  module Helpers
    module Template
      def self.included(klass)
        klass.instance_eval do
          include(InstanceMethods)
          presentation :template
        end
      end
      module InstanceMethods
        def templatify(obj, presentation, *args)
          raise 'No @model defined' unless @model
          # Any key exposed but not explicitally set editable false is editable
          obj['_template'] = self.call(:template)
          obj
        end
        def to_template(*args)
          raise 'No @model defined' unless @model
          # Any key exposed but not explicitally set editable false is editable
          if @model.respond_to?(:to_template)
            template = @model.to_template
          else
            editable = self.class.filtered_exposed_keys(:template, :editable)
            template = editable.inject({}) do |acc, (k,v)|
              acc[k.to_s] = {"value" => (@model.respond_to?(k) ? @model.send(k) : '')}
              acc
            end
          end
          template
        end
        def template(*args)
          {data: to_template}
        end
      end
    end
  end
end
