class SendPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification

    recipient = notification.recipient
    return if recipient.push_subscriptions.none?

    payload = JSON.generate(
      title: "fl4re",
      body:  notification.message,
      path:  notification.path
    )

    vapid = {
      subject:    "mailto:#{Rails.application.config.x.app_email}",
      public_key:  Rails.application.credentials.dig(:vapid, :public_key),
      private_key: Rails.application.credentials.dig(:vapid, :private_key)
    }

    recipient.push_subscriptions.each do |sub|
      WebPush.payload_send(
        message:      payload,
        endpoint:     sub.endpoint,
        p256dh:       sub.p256dh_key,
        auth:         sub.auth_key,
        vapid:        vapid,
        ssl_timeout:  5,
        open_timeout: 5,
        read_timeout: 5
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      sub.destroy
    rescue WebPush::Error => e
      Rails.logger.warn("WebPush error for subscription #{sub.id}: #{e.message}")
    end
  end
end
