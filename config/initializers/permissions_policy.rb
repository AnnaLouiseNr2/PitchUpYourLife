# Be sure to restart your server when you modify this file.

# Define an application-wide HTTP permissions policy. For further
# information see: https://developers.google.com/web/updates/2018/06/feature-policy

Rails.application.config.permissions_policy do |policy|
  policy.camera      :self  # Allow camera for video uploads
  policy.microphone  :self  # Allow microphone for video uploads
  policy.gyroscope   :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :none
  policy.geolocation :none
  policy.accelerometer :none
  policy.magnetometer :none
end
