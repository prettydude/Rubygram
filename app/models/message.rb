class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation

  default_scope { includes(:user) }

  after_create_commit { MessageBroadcastJob.perform_later(self) }

  def as_json(options = {})
    super(options.merge({ include: [:user] }))
  end
end
