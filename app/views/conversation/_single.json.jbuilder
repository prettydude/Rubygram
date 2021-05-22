json.(conversation, :id, :recipient_id, :recipient, :sender_id, :sender)

last = conversation.messages.last
if last
  json.preview last.file.attached? ? 'File' : last.body
  json.last_at last.created_at
end

if @messages
  json.messages conversation.messages.order(:updated_at), partial: 'messages/message', as: :message
  # json.messages conversation.messages
end
