Rails.application.configure do
  config.lograge.base_controller_class = 'ActionController::API'
  config.lograge.enabled = true
  config.lograge.ignore_actions = ['ConversationChannel#uploadAvatar', 'MessageChannel#sendMessage']
end
