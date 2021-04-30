class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "conversations-#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end

  def getConversation(data)
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: "getConversation",
        conversation: Conversation.includes(:recipient, :messages)
                                    .get(current_user.id, data["peer_id"])
      }
    )
  end

  def getConversationInfo(data)
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: "getConversationInfo",
        conversation: Conversation.includes(:recipient, :messages)
                                    .get(current_user.id, data["peer_id"])
      }
    )
  end

  def allConversations()
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: "allConversations",
        conversations: Conversation.includes(:recipient, :messages)
                                   .with(current_user.id)
                                   .select { |x| x.messages.length } #don't return empty conversations
      }
    )
  end

  def allUsers()
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: "allUsers",
        users: User.all
      }
    )
  end

end
