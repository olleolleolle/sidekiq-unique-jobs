# frozen_string_literal: true

module SidekiqUniqueJobs
  module OnConflict
    # Strategy to reschedule job on conflict
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    class Reschedule < OnConflict::Strategy
      include SidekiqUniqueJobs::SidekiqWorkerMethods
      include SidekiqUniqueJobs::Logging
      include SidekiqUniqueJobs::JSON

      # @param [Hash] item sidekiq job hash
      def initialize(item, redis_pool = nil)
        super(item, redis_pool)
        @worker_class = item[CLASS]
      end

      # Create a new job from the current one.
      #   This will mess up sidekiq stats because a new job is created
      def call
        if sidekiq_worker_class?
          log_info("Rescheduling #{item[UNIQUE_DIGEST]}")
          worker_class&.perform_in(5, *item[ARGS])
        else
          log_warn("Skip rescheduling of #{item[UNIQUE_DIGEST]} because #{worker_class} is not a Sidekiq::Worker")
        end
      end
    end
  end
end
