module HalPresenters
  module Helpers
    module Rels
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.instance_eval do
          include(InstanceMethods)
        end
      end
      module ClassMethods
        # Define a rel and the href that goes with it
        def rel(name, opts = {}, &block)
          name = "#{self.rel_name}#{name}" if name =~ /^:/
          opts = HalPresenters.normalize_options(opts)
          stored_rels[name] = [opts, block]
        end

        # What this object will be linked as.
        def rel_name(name = nil)
          @rel_name = name if name
          @rel_name
        end

        # List of rels defined with #rel
        # Rels are stored as keys, with procs for each rel
        def stored_rels
          @stored_rels ||= {}
          @stored_rels
        end

        # List of rel keys optionally filtered by presentation
        def rels(presentation = nil)
          if presentation
            stored_rels.reject{|k, (v,p)|
              HalPresenters.exclude_presentation?(v, presentation)
            }.keys
          else
            stored_rels.keys
          end
        end

      end
      module InstanceMethods
        # Filter to add link hash based on class level rels
        def linkify(obj, presentation = :full, *args)
          obj["_links"] = self.link_hash_for(presentation)
          selfify(obj, presentation, *args)
        end

        # Set self if overridden
        def selfify(obj, presentation = :full, *args)
          obj["_links"]["self"] = prep_link(options[:self], "self") if options[:self] && options[:override_self]
          obj
        end

        # Builds a hash of class rels defined, filtered by presentation
        def link_hash_for(presentation = :full)
          self.class.rels(presentation).inject({}) do |hash, rel|
            link = self.link_for_rel(rel, presentation)
            hash[rel] = link unless link.nil?
            hash
          end
        end

        # Prepares an individual rel,
        # calling the defined rel block and calling
        # prep link on the returned value to prepare for return
        def link_for_rel(rel, presentation_type = nil)
          opts, link_proc = self.class.stored_rels[rel]
          ret = instance_exec(self, opts, presentation_type, &link_proc)
          if ret.is_a?(Array)
            if ret.size > 1
              ret = ret.map{|l| prep_link(l, rel)}.compact
            else
              ret = prep_link(ret.compact.first, rel)
            end
          else
            ret = prep_link(ret, rel)
          end
          ret
        end

        # Prep link takes a return value, which may be a hash or
        # string, and turns it into a hash with the rel set.
        # prep_link("foo", "bar") => {href: "foo", rel: "bar"}
        # prep_link({href: "banana", test: "foo"}, "bar") =>
        #   {test: "foo", href: "banana", rel: "bar"}
        def prep_link(ret, rel)
          ret = {href: ret} unless ret.respond_to?(:fetch)
          return nil unless ret[:href]
          ret[:href] = "#{self.options[:root]}#{ret[:href]}" if self.options[:root] && ret[:href] =~ /^\//
          ret[:templated] = true if ret[:href] =~ /\{.*\}/
          if ret[:templated] && ret[:'href-vars'].nil?
            vars = Addressable::Template.new(ret[:href]).variables
            # Assume all variables are string type
            ret[:'href-vars'] = vars.inject({}){|acc, var| acc[var] = "string"; acc }
          end
          ret[:rel] = rel
          ret
        end
      end
    end
  end
end
