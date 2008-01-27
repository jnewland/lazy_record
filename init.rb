require 'active_record/lazy'
require 'active_record/lazy/record'
ActiveRecord::Base.class_eval do
  include ActiveRecord::Lazy
  class << self
    alias_method :find_without_lazy, :find
  end
  include ActiveRecord::Lazy::Record
end