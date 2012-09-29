module HalPresenters
  module Helpers
    module Collection
      def initialize(item, opts = {})
        @options = opts
        @model =  OpenStruct.new(list: item)
      end
      def reset(item, opts = {})
        @options = opts
        @model =  OpenStruct.new(list: item)
        self
      end
    end
  end
end
