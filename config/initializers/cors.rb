# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # List your trusted domains here
    origins 'a3c9fcb6a9c8c41f193c6da2d2d54132-1680654621.ap-south-1.elb.amazonaws.com', 'a474331ab38e54d169db3f3710f45153-807236935.ap-south-1.elb.amazonaws.com', 'a5bd5bc320ef64adbba1934563bcd64b-997637156.ap-south-1.elb.amazonaws.com', 'a3d49441dc6084ea38664901c6075d65-1747963472.ap-south-1.elb.amazonaws.com', 'aed8ca98b0f9a458d84704fa66a72984-855932334.ap-south-1.elb.amazonaws.com'

    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             credentials: true # If you need to send cookies or other credentials
  end
end