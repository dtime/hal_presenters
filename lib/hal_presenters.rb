require "hal_presenters/version"
require 'ostruct'

Dir.glob(File.join(File.dirname(__FILE__), "hal_presenters", "helpers", "*.rb")){ |file| require file}

module HalPresenters
  # Your code goes here...
  # Normalizes options so they have defaults as expected
  def self.normalize_options(opts)
    opts[:only] = [opts[:only]].flatten.compact
    opts[:except] = [opts[:except]].flatten.compact
    opts
  end
  # Helper for easily handling :only and :except options
  def self.exclude_presentation?(opts, presentation)
    (!opts[:only].empty? && !opts[:only].include?(presentation)) ||
    (!opts[:except].empty? && opts[:except].include?(presentation))
  end
end
