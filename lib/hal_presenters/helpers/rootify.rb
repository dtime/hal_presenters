module HalPresenters
  module Helpers
    module Rootify
      def self.included(klass)
        klass.instance_eval do
          include(InstanceMethods)
          default_after_filter :absolutify
          default_after_filter :rootify
        end
      end
      module InstanceMethods
        # Add dtime:root if it doesn't exist and
        # this is not embedded (:full)
        def rootify(obj, presentation, *args)
          return obj unless self.options[:root]
          return obj unless (presentation == :full || self.class.respond_to?(:presentations) && self.class.presentations[presentation].include?(:rootify))
          obj["_links"] ||= {}
          obj = curify(obj, presentation, *args)
          return obj unless obj.respond_to?(:fetch)  && obj["_links"]
          return obj if obj["_links"]["dtime:root"]
          obj["_links"]["dtime:root"] = {href: "#{self.options[:root]}/", rel: "dtime:root"}
          obj
        end

        # Add curie if it doesn't exist
        def curify(obj, presentation, *args)
          return obj if obj["_links"]["curie"]
          obj["_links"]["curie"] = {name: 'dtime', href: "#{self.options[:root]}/docs/rels/{+relation}", rel: "curie", templated: true}
          obj
        end

        # Add root to all links in nested hash
        def absolutify(obj, *args)
          return obj unless self.options[:root]
          return obj unless obj.respond_to?(:each)
          if obj.is_a?(Array)
            obj.map{|a| absolutify(a, *args)}
          else
            obj.each do |k, v|
              if k.to_s == "href" && v.is_a?(String) && v =~ /^\//
                obj[k] = "#{self.options[:root]}#{v}"
              elsif v.respond_to?(:each)
                obj[k] = absolutify(v, *args)
              end
            end
          end
          obj
        end
      end
    end
  end
end
