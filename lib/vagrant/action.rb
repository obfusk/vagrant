module Vagrant
  # Manages action running and registration. Every Vagrant environment
  # has an instance of {Action} to allow for running in the context of
  # the environment.
  class Action
    include Util

    class << self
      # Returns the list of registered actions.
      def actions
        @actions ||= {}
      end

      # Registers an action and associates it with a symbol. This
      # symbol can then be referenced in other action builds and
      # callbacks can be registered on that symbol.
      #
      # @param [Symbol] key
      def register(key, callable)
        actions[key] = callable
      end
    end

    # The environment to run the actions in.
    attr_reader :env

    # Initializes the action with the given environment which the actions
    # will be run in.
    #
    # @param [Environment] env
    def initialize(env)
      @env = env
    end

    # Runs the given callable object in the context of the environment.
    # If a symbol is given as the `callable` parameter, then it is looked
    # up in the registered actions list which are registered with {register}.
    #
    # @param [Object] callable An object which responds to `call`.
    def run(callable)
      callable = self.class.actions[callable] if callable.kind_of?(Symbol)

      action_environment = Action::Environment.new(env)
      callable.call(action_environment)

      if action_environment.error?
        # Erroneous environment resulted. Properly display error
        # message.
        key, options = action_environment.error
        error_and_exit(key, options)
        return false
      end
    end
  end
end
