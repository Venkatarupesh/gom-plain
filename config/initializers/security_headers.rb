# config/initializers/security_headers.rb

# Set HSTS (HTTP Strict Transport Security) header
Rails.application.config.action_dispatch.default_headers.merge!(
  'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains'
)

# Set other security headers
Rails.application.config.action_dispatch.default_headers.merge!(
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block',
  'Content-Security-Policy' => "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self';"
)
