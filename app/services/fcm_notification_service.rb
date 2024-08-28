class FcmNotificationService
  def initialize(fcm_token, data)
    @fcm_token = fcm_token
    @data = data
  end

  def send_notification
    fcm = FCM.new(
      'nil',
      "lib/hwc-gok-b2554d877acd.json",
      "hwc-gok"
    )

    message = {
      'token': @fcm_token,
      'data': @data,
      'notification': {},
      'android': {
        "priority":"high"
      },
      'apns': {
        payload: {
          aps: {
            sound: "default",
            category: "#{Time.zone.now.to_i}"
          }
        }
      },
      'fcm_options': {}
    }

    begin
      response = fcm.send_v1(message)
    rescue StandardError => e
      response = e.message
    end

    crumb = Sentry::Breadcrumb.new(
      message: response.to_s,
      timestamp: Time.now.to_i
    )
    Sentry.add_breadcrumb(crumb)
  end
end
