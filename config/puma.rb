# Change to match your CPU core count
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
# Min and Max threads per worker
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 6)
threads threads_count, threads_count
preload_app!
# rackup      DefaultRackup
# port        ENV['PORT']     || 3000
# Default to production
rails_env = ENV['RAILS_ENV'] || "development"
environment rails_env
# # Set up socket location
# bind "unix://tmp/puma.sock"
queue_requests false
bind "tcp://0.0.0.0:3000"
# # Logging
# stdout_redirect "#{app_dir}/shared/log/puma.stdout.log", "shared/log/puma.stderr.log", true
#Set master PID and state locations
#  pidfile "#{app_dir}/shared/pids/puma.pid"

# state_path "#{app_dir}/shared/pids/puma.state"

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
wait_for_less_busy_worker 0.005
# worker_timeout 60
# wait_for_less_busy_worker ENV.fetch('PUMA_WAIT_FOR_LESS_BUSY_WORKER', 0.001).to_f
