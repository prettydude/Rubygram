json.(conversation, :id, :recipient_id, :recipient, :sender_id, :sender)
json.preview conversation.messages.last&.body
json.last_at conversation.messages.last&.created_at

if @messages
  json.messages conversation.messages
end
