json.(message, :id, :conversation_id, :user_id, :user, :body, :created_at, :updated_at)

if message.file.attached?
  json.file message.file.blob
  json.file_url message.file_url
end
