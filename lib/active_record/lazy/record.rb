module ActiveRecord
  module Lazy #:nodoc:
    module Record
  
      def self.append_features(base)
        super
        base.extend(ClassMethods)  
      end

    
      module ClassMethods      
        #lazy finder
        def lazy_find(*args)
          ActiveRecord::Lazy.promise { find_without_lazy(*args) }
        end
      
        def lazy_record()    
          class << self
            alias_method :find, :lazy_find
          end
        end
      
      end
    end
  end
end