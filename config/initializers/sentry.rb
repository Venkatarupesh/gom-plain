Sentry.init do |config|
  # config.background_worker_threads = 2
  config.dsn = 'http://5249f93bd086715b256b24663faab2c6@a0b69c496864d42bea8e914f9c52742c-1576378846.ap-south-1.elb.amazonaws.com/2'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.enable_tracing = true
  config.metrics.enabled = true

  config.before_send_transaction = lambda do |event, _hint|
    # skip unimportant transactions

    if event.request.url.match?("/api/health_check")
      # don't send the event to Sentry
      nil
    else
      event
    end
  end

  # if event.transaction == "/unimportant/healthcheck/route"
  #   # don't send the event to Sentry
  #   nil
  # end
  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  config.profiles_sample_rate = 1.0

  # or
  config.traces_sampler = lambda do |context|
    true
  end
end
