# Interactor::Jobify

Integrates interactors with background job queues (e.g., Sidekiq, ActiveJob). Allows conditional async execution.

**Example:**
```ruby
class UserInteractorJob < AsyncJob
  queue_as :default

  def perform(params)
    user = User.find(params[:user_id])
    ::UserInteractor.call!(user: user)
  end
end

class UserInteractor
  include Interactor::Operation

  # you can pass klass name
  # jobify(klass: AnotherJob)
  # jobify(default: true) # it jobify by default
  jobify { |interactor| { user_id: interactor.user.id } }
  
  input :user, User

  def call
    logger.debug "Processing user: #{user.email}"
  end
end

# Synchronous execution
UserInteractor.call!(user: User.first)

# Asynchronous execution
UserInteractor.call!(user: User.first, jobify: true)
```

[Back to README](../README.md)
