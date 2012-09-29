module HalPresenters
  module Helpers
    module Embeddable
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
      module ClassMethods
        def expose_embedded(key, presenter = nil, opts = {})
          opts = HalPresenters.normalize_options(opts)
          exposed_embeds[key] = [presenter, opts]
        end
        def exposed_embeds
          @exposed_embeds ||= {}
          @exposed_embeds
        end
        def filtered_exposed_embeds(type)
          exposed_embeds.reject{|key, (val, opts)|
            HalPresenters.exclude_presentation?(opts, type)
          }
        end
      end
      module InstanceMethods
        def embedify(obj, presentation = :full, *args)
          obj["_embedded"] ||= {}
          self.class.filtered_exposed_embeds(presentation).each do |key, (val, opts)|
            if self.respond_to?(key.to_sym)
              embedded = self.send(key.to_sym)
            elsif @model.respond_to?(key.to_sym)
              embedded = @model.send(key.to_sym)
            end
            val = embedded.presenter if !val && embedded.respond_to?(:presenter)
            if val
              rel = opts[:as] || val.rel_name
              if embedded.respond_to?(:each)
                obj["_embedded"][rel] = embedded.map{|i|
                  case val
                  when Symbol
                    self.send(val, i, presentation)
                  else
                    val.present(:embedded, i)
                  end
                }
              elsif embedded.nil?
                obj["_embedded"][rel] = nil
              else
                obj["_embedded"][rel] = case val
                                        when Symbol
                                          self.send(val, embedded, presentation)
                                        else
                                          val.present(:embedded, embedded)
                                        end
              end
            end
          end
          obj
        end
        def embedded(*args)
          raise 'No @model defined' unless @model
          self.exposed_model(:full)
        end
      end
    end
  end
end
