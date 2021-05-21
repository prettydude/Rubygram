# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
  include Rails.application.routes.url_helpers

  has_one_attached :avatar

  has_many :messages
  has_many :conversations, foreign_key: :sender_id

  default_scope { with_attached_avatar }

  before_save { email.downcase! }

  VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates_presence_of :nickname
  validates_uniqueness_of :nickname
  validates_presence_of :name

  validate :acceptable_avatar

  def acceptable_avatar
    return unless avatar.attached?
  
    unless avatar.byte_size <= 5.megabyte
      errors.add(:avatar, "is too big")
    end
  
    acceptable_types = ["image/jpeg", "image/jpg", "image/png"]
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, "must be a JPEG or PNG")
    end
  end

  def self.search(search)
    if search && !search.empty?
      where('name LIKE ? OR nickname LIKE ?', "%#{search}%", "%#{search}%").limit(10)
    else
      last(10)
    end
  end

  def as_json(options = {})
    super(options.merge({ except: [:provider, :email, :uid, :created_at, :updated_at, :allow_password_change] })).merge({
      'avatar_url': avatar.attached? ? url_for(self.avatar) : nil
    })
  end

end
