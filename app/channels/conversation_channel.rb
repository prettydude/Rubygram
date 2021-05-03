class ConversationChannel < ApplicationCable::Channel
  include ChannelHelper

  def subscribed
    stream_from "conversations-#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end

  def checkConnection() 
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: "checkConnection",
        response: "OK"
      }
    )
  end

  def getConversation(data)
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: "getConversation",
        conversation: render_json(
          template: 'conversation/basic',
          assigns: { 
            conversation: Conversation.get(current_user.id, data["peer_id"]),
            messages: true 
          }
        )
      }
    )
  end

  def getConversationInfo(data)
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: "getConversationInfo",
        conversation: render_json(
          template: 'conversation/basic',
          assigns: { conversation: Conversation.get(current_user.id, data["peer_id"]) }
        )
      }
    )
  end

  def allConversations()
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: "allConversations",
        conversations: render_json(
          template: 'conversation/list',
          assigns: { conversations: Conversation.with(current_user.id)
            .select { |x| x.messages.length } # don't return empty conversations
          }
        )
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

  def sendTyping(data)
    ActionCable.server.broadcast(
      "conversations-#{data["peer_id"]}",
      {
        type: "typing",
        conversation_id: Conversation.get(current_user.id, data["peer_id"]).id
      }
    )
  end

end
