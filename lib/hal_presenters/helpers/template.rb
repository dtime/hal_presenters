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
        def to_create_template(*args)
          @model ||= Hashie::Mash.new
          # Any key exposed but not explicitally set editable false is editable
          if @model.respond_to?(:to_template)
            template = @model.to_create_template
          else
            editable = self.class.filtered_exposed_keys(:template, :editable)
            template = editable.each_with_object({}) do |(k,v), acc|
              default = (@model.respond_to?(k) ? @model.send(k) : '')
              info = v.dup.delete_if{|k,_| [:only,:except,:description,:as].include?(k)}
              info[:title] ||= (v[:description] || '')
              info[:type] ||= 'string'
              acc[k.to_s] = info.merge({"default" => default})
            end
          end
          {properties: template}
        end
        def to_template(*args)
          raise 'No @model defined' unless @model
          # Any key exposed but not explicitally set editable false is editable
          if @model.respond_to?(:to_template)
            template = @model.to_template
          else
            editable = self.class.filtered_exposed_keys(:template, :editable)
            template = editable.each_with_object({}) do |(k,v), acc|
              acc[k.to_s] = {"value" => (@model.respond_to?(k) ? @model.send(k) : '')}
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
