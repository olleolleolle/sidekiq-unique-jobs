# frozen_string_literal: true

module SidekiqUniqueJobs
  #
  # Base class for all exceptions raised from the gem
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class UniqueJobsError < ::RuntimeError
  end

  # Error raised when a Lua script fails to execute
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  class Conflict < UniqueJobsError
    def initialize(item)
      super("Item with the key: #{item[UNIQUE_DIGEST]} is already scheduled or processing")
    end
  end

  #
  # Error raised when trying to add a duplicate lock
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class DuplicateLock < UniqueJobsError
  end

  #
  # Error raised when trying to add a duplicate stragegy
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class DuplicateStrategy < UniqueJobsError
  end

  #
  # Error raised when an invalid argument is given
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class InvalidArgument < UniqueJobsError
  end

  #
  # Raised when a workers configuration is invalid
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class InvalidWorker < UniqueJobsError
    def initialize(lock_config)
      super(<<~FAILURE_MESSAGE)
        Expected #{lock_config.worker} to have valid sidekiq options but found the following problems:
        #{lock_config.errors_as_string}
      FAILURE_MESSAGE
    end
  end

  # Error raised when a Lua script fails to execute
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  class InvalidUniqueArguments < UniqueJobsError
    def initialize(given:, worker_class:, unique_args_method:)
      uniq_args_meth  = worker_class.method(unique_args_method)
      num_args        = uniq_args_meth.arity
      # source_location = uniq_args_meth.source_location

      super(
        "#{worker_class}#unique_args takes #{num_args} arguments, received #{given.inspect}"
      )
    end
  end

  #
  # Raised when a workers configuration is invalid
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class NotUniqueWorker < UniqueJobsError
    def initialize(options: {})
      super("#{options[:class]} is not configured for uniqueness. Missing the key `:lock` in #{options.inspect}")
    end
  end

  # Error raised from {OptionsWithFallback#lock_class}
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  class UnknownLock < UniqueJobsError
  end
end
