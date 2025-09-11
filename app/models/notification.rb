class Notification < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true
  validates :notification_type, presence: true

  enum notification_type: {
    tournament_organization: 'tournament_organization',
    general_inquiry: 'general_inquiry',
    support: 'support'
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }

  def formatted_created_at
    created_at.strftime("%d/%m/%Y à %H:%M")
  end
end
