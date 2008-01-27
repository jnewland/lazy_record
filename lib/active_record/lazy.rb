# = lazy.rb -- Lazy evaluation in Ruby
#
# Author:: MenTaLguY
#
# Copyright 2005-2006  MenTaLguY <mental@rydia.net>
#
# You may redistribute it and/or modify it under the same terms as Ruby.
#

module ActiveRecord
  module Lazy

    # Raised when a demanded computation diverges (e.g. if it tries to directly
    # use its own result)
    #
    class DivergenceError < Exception
      def initialize( message="Computation diverges" )
        super( message )
      end
    end

    # Wraps an exception raised by a lazy computation.
    #
    # The reason we wrap such exceptions in LazyException is that they need to
    # be distinguishable from similar exceptions which might normally be raised
    # by whatever strict code we happen to be in at the time.
    #
    class LazyException < DivergenceError
      # the original exception
      attr_reader :reason

      def initialize( reason )
        @reason = reason
        super( "Exception in lazy computation: #{ reason } (#{ reason.class })" )
        set_backtrace( reason.backtrace.dup ) if reason
      end
    end

    # A handle for a promised computation.  They are transparent, so that in
    # most cases, a promise can be used as a proxy for the computation's result
    # object.  The one exception is truth testing -- a promise will always look
    # true to Ruby, even if the actual result object is nil or false.
    #
    # If you want to test the result for truth, get the unwrapped result object
    # via #demand.
    #
    class Promise
      alias __class__ class #:nodoc:
      instance_methods.each { |m| undef_method m unless m =~ /^__/ }

      def initialize( &computation ) #:nodoc:
        @computation = computation
      end
      def __synchronize__ #:nodoc:
        yield
      end

      # create this once here, rather than creating a proc object for
      # every evaluation
      DIVERGES = lambda { raise DivergenceError.new } #:nodoc:
      def DIVERGES.inspect #:nodoc:
        "DIVERGES"
      end

      def __result__ #:nodoc:
        __synchronize__ do
          if @computation
            raise LazyException.new( @exception ) if @exception

            computation = @computation
            @computation = DIVERGES # trap divergence due to over-eager recursion

            begin
              @result = ActiveRecord::Lazy.demand( computation.call( self ) )
              @computation = nil
            rescue DivergenceError
              raise
            rescue Exception => exception
              # handle exceptions
              # @exception = exception
              raise exception
              # raise LazyException.new( @exception )
            end
          end

          @result
        end
      end

      def inspect #:nodoc:
        __synchronize__ do
          if @computation
            "#<#{ __class__ } computation=#{ @computation.inspect }>"
          else
            @result.inspect
          end
        end
      end

      def respond_to?( message ) #:nodoc:
        message = message.to_sym
        message == :__result__ or
        message == :inspect or
        __result__.respond_to? message
      end

      def method_missing( *args, &block ) #:nodoc:
        __result__.__send__( *args, &block )
      end
    end
    
    # The promise() function is used together with demand() to implement
    # lazy evaluation.  It returns a promise to evaluate the provided
    # block at a future time.  Evaluation can be demanded and the block's
    # result obtained via the demand() function.
    #
    # Implicit evaluation is also supported: the first message sent to it will
    # demand evaluation, after which that message and any subsequent messages
    # will be forwarded to the result object.
    #
    # As an aid to circular programming, the block will be passed a promise
    # for its own result when it is evaluated.  Be careful not to force
    # that promise during the computation, lest the computation diverge.
    #
    def self.promise( &computation ) #:yields: result
      ActiveRecord::Lazy::Promise.new &computation
    end

    # Forces the result of a promise to be computed (if necessary) and returns
    # the bare result object.  Once evaluated, the result of the promise will
    # be cached.  Nested promises will be evaluated together, until the first
    # non-promise result.
    #
    # If called on a value that is not a promise, it will simply return it.
    #
    def self.demand( promise )
      if promise.respond_to? :__result__
        promise.__result__
      else # not really a promise
        promise
      end
    end

  end
end