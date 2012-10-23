module HalPresenters
  module Helpers
    module Exposable
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.instance_eval do
          include(InstanceMethods)
        end
      end
      module ClassMethods
        # Helper for extracting opts and a description from
        # zero, one or two arguments
        def extract_options_with_defaults(defaults, *args)
          opts = args.pop
          defaults[:description] = opts if opts.is_a?(String)
          opts = {} unless opts.is_a?(Hash)
          defaults[:description] = args.first if args.first.is_a?(String)
          opts = defaults.merge(opts)
          opts = HalPresenters.normalize_options(opts)
          opts
        end

        # Main method for adding exposed keys
        # Called by helpers below
        def add_exposed(key, defaults, *args)
          opts = extract_options_with_defaults(defaults, *args)
          opts[:as] = key.to_s unless opts[:as]
          all_exposed[key.to_sym] = opts
        end

        def all_exposed
          @all_exposed ||= {}
          @all_exposed
        end

        def filtered_exposed_keys(type, filter_type = :presentation)
          case filter_type
          when :presentation
            all_exposed.reject{|key, opts|
              HalPresenters.exclude_presentation?(opts, type)
            }
          when :editable
            all_exposed.select{|k,v| v[:editable] == true || v[:editable].nil? }
          else
            all_exposed
          end
        end

        # Define a editable: false exposed key
        # (templates only show editable keys)
        def readable(key, *args)
          defaults = {editable: false}
          add_exposed(key, defaults, *args)
        end
        alias :reads :readable

        def expose_list(key, presenter, *args)
          defaults = {presenter: presenter, list: true, as: :result, presentation: :embedded}
          add_exposed(key, defaults, *args)
        end
        def expose(key, *args)
          defaults = {}
          add_exposed(key, defaults, *args)
        end
        alias :exposed :expose
        alias :exposes :expose
        alias :decorated :expose
        alias :decorates :expose
      end
      module InstanceMethods
        def exposed_model(type)
          self.class.filtered_exposed_keys(type).inject({}) do |hash, (key, opts)|
            # By default, we always pass through to model
            # Has to be explicitly decorated if required
            # (define key with decorates instead of exposes)
            target = @model
            target = self if opts[:decorated] || self.respond_to?(key)
            if opts[:list]
              hash[opts[:as]] = target.send(key).map{|i|
                # Present list item with a presenter method if symbol
                if opts[:presenter].is_a?(Symbol)
                  self.send(opts[:presenter], i, type)
                # Or the class' own presenter if defined
                elsif i.respond_to?(:presenter)
                  i.presenter.new(i).call(opts[:presentation])
                # Or the presenter object as a class, if defined that way
                else
                  opts[:presenter].new(i).call(opts[:presentation])
                end
              }
            else
              hash[opts[:as]] = target.send(key)
            end
            hash
          end
        end
        def full(*args)
          raise 'No @model defined' unless @model
          exposed_model(:full)
        end
      end
    end
  end
end
