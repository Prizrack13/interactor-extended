# frozen_string_literal: true

module Interactor
  # Provides jobify functionality to interactor classes, allowing them to be executed as background jobs.
  module Jobify
    include Interactor::Extended::Helpers

    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      attr_reader :job_active, :job_class, :job_default, :job_params

      # Configures the interactor to be jobified.
      # @param klass [Class, nil] The job class to use. Defaults to `#{self.class.name}Job`.
      # @param params [untyped, nil] Parameters to pass to the job. Can be a Proc.
      # @param default [bool] Whether jobify is enabled by default.
      # @yield [interactor] Yields the interactor instance to generate params.
      def jobify(klass: nil, params: nil, default: false, &block)
        @job_active = true
        @job_class = klass
        @job_default = default
        @job_params = params || block
      end
    end

    # Returns whether the job is active.
    # @return [bool, nil]
    def job_active
      self.class.job_active
    end

    # Returns whether the job is enabled by default.
    # @return [bool]
    def job_default
      self.class.job_default
    end

    # Runs the interactor, potentially as a job.
    # @return [untyped]
    def run!
      return super if !jobify? || !job_active

      with_hooks { perform_job(job_params) }
    end

    protected

    # Determines if jobify should be used based on context or default.
    # @return [bool]
    def jobify?
      context[:jobify].nil? ? job_default : context[:jobify]
    end

    # Returns the job class.
    # @return [Class]
    def job_class
      self.class.job_class || Object.const_get("#{self.class.name}Job")
    end

    # Returns the job parameters.
    # @return [untyped]
    def job_params
      self.class.job_params&.call(self)
    end

    # Checks if the job should be performed with a delay.
    # @return [bool]
    def perform_in?
      context[:jobify].to_s.to_i.positive?
    end

    # Performs the job with the given parameters.
    # @param params [untyped] The parameters for the job.
    # @return [void]
    def perform_job(params = nil)
      args = (params || context.to_h.reject { |key| key.match(/^_/) }).then do |parameters|
        parameters.respond_to?(:as_json) ? parameters.as_json : deep_transform_keys(parameters, &:to_s)
      end
      perform_in? ? perform_in(context[:jobify].to_i, args) : perform_later(args)
    end

    # Performs the job later (asynchronously).
    # @param args [untyped] The arguments for the job.
    # @return [void]
    def perform_later(args)
      return job_class.perform_later(args) if job_class.respond_to?(:perform_later)

      job_class.perform_async(args) if sidekiq?
    end

    # Performs the job in with a delay.
    # @param wait [untyped] The delay duration.
    # @param args [untyped] The arguments for the job.
    # @return [void]
    def perform_in(wait, args)
      return job_class.perform_in(wait, args) if job_class.respond_to?(:perform_in)

      job_class.set(wait:).perform_later(args) if application_job?
    end

    # Checks if jos class is Sidekiq.
    # @return [bool]
    def sidekiq?
      SidekiqJob.included_modules.include?(Sidekiq::Job)
    rescue StandardError
      false
    end

    # Checks if job class is ApplicationJob.
    # @return [bool]
    def application_job?
      ApplicationJob.superclass == ActiveJob::Base
    rescue StandardError
      false
    end
  end
end
