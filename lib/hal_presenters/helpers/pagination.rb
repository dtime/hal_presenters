module HalPresenters
  module Helpers
    module Pagination
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
        klass.class_eval do
          rel "self" do
            "#{options[:self]}#{current_page}"
          end
          rel "next" do
            if next_page
              "#{options[:self]}#{next_page}"
            end
          end
          rel "prev" do
            if prev_page
              "#{options[:self]}#{prev_page}"
            end
          end
        end
      end
      module InstanceMethods
        def next_page
          if a = options.fetch(:after, nil)
            "?page_size=#{page_size}&after=#{a}"
          else
            nil
          end
        end
        def prev_page
          if b = options.fetch(:before, nil)
            "?page_size=#{page_size}&before=#{b}"
          else
            nil
          end
        end

        def current_page
          if b = options.fetch(:current_before, nil)
            "?page_size=#{page_size}&before=#{b}"
          elsif a = options.fetch(:current_after, nil)
            "?page_size=#{page_size}&after=#{a}"
          elsif options.fetch(:page_size, nil)
            "?page_size=#{page_size}"
          else
            nil
          end
        end

        def page_size
          options.fetch(:page_size, 25)
        end
      end
    end
  end
end
