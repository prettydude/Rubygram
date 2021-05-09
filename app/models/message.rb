class Message < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :user
  belongs_to :conversation

  default_scope { includes(:user) }
  default_scope { with_attached_file }

  has_one_attached :file

  # validates_presence_of :body

  after_create_commit { MessageBroadcastJob.perform_later(self) }

  after_destroy_commit { MessageDeleteBroadcastJob.perform_now(self) }

  def as_json(options = {})
    super(options.merge({ include: [:user] })).merge({
      'file_url': file.attached? ? url_for(file) : nil,
      'file': file ? file.blob : nil
    })
  end
end
