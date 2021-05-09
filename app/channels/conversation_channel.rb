class ConversationChannel < ApplicationCable::Channel
  include ChannelHelper

  def subscribed
    stream_from "conversations-#{current_user.id}"
    stream_from "global_conversations"
  end

  def unsubscribed
    stop_all_streams
  end

  def checkConnection() 
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: 'checkConnection',
        response: 'OK'
      }
    )
  end

  def getConversation(data)
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: 'getConversation',
        conversation: render_json(
          template: 'conversation/basic',
          assigns: {
            conversation: Conversation.get(current_user.id, data['peer_id']),
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
        type: 'getConversationInfo',
        conversation: render_json(
          template: 'conversation/basic',
          assigns: { conversation: Conversation.find(data['conversation_id']) }
        )
      }
    )
  end

  def allConversations()
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: 'allConversations',
        conversations: render_json(
          template: 'conversation/list',
          assigns: { conversations: Conversation.with(current_user.id).has_messages }
        )
      }
    )
  end

  def allUsers()
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: 'allUsers',
        users: User.all
      }
    )
  end

  def sendTyping(data)
    ActionCable.server.broadcast(
      "conversations-#{data['peer_id']}",
      {
        type: 'typing',
        conversation_id: Conversation.get(current_user.id, data['peer_id']).id
      }
    )
  end

  def searchUsers(data)
    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      {
        type: 'searchUsers',
        users: User.search(data['query'])
      }
    )
  end

  def uploadAvatar(data)
    # current_user.avatar.purge if current_user.avatar.attached?

    file = Tempfile.new(Time.now.to_i.to_s, binmode: true)
    file.write(data['bytes'].pack('C*'))
    file.rewind
    current_user.avatar.attach(io: file, filename: Time.now.to_i.to_s, content_type: data['content_type'])

    ActionCable.server.broadcast(
      'global_conversations',
      {
        type: 'updateAvatar',
        user: current_user
      }
    )
  end
end
