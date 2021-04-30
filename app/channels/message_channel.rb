class MessageChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages-#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end

  def sendMessage(data)
    sender_id = current_user.id
    recipient_id = data['peer']['id']
    text = data['message']['text']

    Message.create(user_id: sender_id, conversation: Conversation.get(sender_id, recipient_id), body: text)
    # ActionCable.server.broadcast(
    #   "messages-#{current_user.id}",
    #   {type: "newMessage", message: message_params}
    # )
  end

  def getMessages(data)
    peer = data['peer']
    ActionCable.server.broadcast(
      "messages-#{current_user.id}",
      {
        type: "messages",
        messages: Conversation.between(current_user.id, peer['id']).messages.as_json(include: :user)
      }
    )
  end

end
