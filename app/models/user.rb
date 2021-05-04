# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  before_save { email.downcase! }

  VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates_presence_of :nickname
  validates_uniqueness_of :nickname
  validates_presence_of :name

  has_many :messages
  has_many :conversations, foreign_key: :sender_id

  def self.search(search)
    if search
      where('[name] LIKE ? OR nickname LIKE ?', "%#{search}%", "%#{search}%")
    else
      Users.first(3)
    end
  end

  def as_json(options = {})
    super(options.merge({ except: [:provider, :uid, :created_at, :updated_at, :allow_password_change] }))
  end

end
