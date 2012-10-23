module HalPresenters
  module Helpers
    module Controllable
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.instance_eval do
          include(InstanceMethods)
        end
      end
      module ClassMethods

        def all_controls
          @all_controls ||= {}
          @all_controls
        end

        def control(name, opts = {}, &block)
          name = "#{self.rel_name}#{name}" if name =~ /^:/
          opts = HalPresenters.normalize_options(opts)
          opts = {
            method: 'POST',
            headers: {
               "Content-Type" => "application/json"
            }
          }.merge(opts)
          all_controls[name] = [opts, Proc.new]
        end

        # List of control keys optionally filtered by presentation
        def controls(presentation = nil)
          if presentation
            all_controls.reject{|k, (v,p)|
              HalPresenters.exclude_presentation?(v, presentation)
            }.keys
          else
            all_controls.keys
          end
        end
      end
      module InstanceMethods
        # Filter to add link hash based on class level rels
        def controlify(obj, presentation = :full, *args)
          obj["_controls"] ||= self.control_hash_for(presentation)
          obj
        end

        # Builds a hash of controls
        def control_hash_for(presentation = :full)
          self.class.controls(presentation).each_with_object({}) do |rel, hash|
            link = self.hash_for_control_rel(rel, presentation)
            hash[rel] = link unless link.nil?
          end
        end

        # Prepares an individual control
        def hash_for_control_rel(rel, presentation_type = nil)
          default_control, control_proc = self.class.all_controls[rel]
          control = default_control.dup.delete_if{|k,_| [:only, :except].include?(k) }
          custom_bits = instance_exec(self, default_control, presentation_type, &control_proc)
          control.merge(custom_bits)
        end
      end
    end
  end
end
