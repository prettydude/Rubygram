class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    sender = message.user
    recipient = message.conversation.opposed_user(sender)

    broadcast(sender, message)
    broadcast(recipient, message) if sender != recipient
  end

  private

  def broadcast(user, message)
    ActionCable.server.broadcast(
      "messages-#{user.id}",
      {
        type: 'newMessage',
        message: message,
      }
    )
  end
end
