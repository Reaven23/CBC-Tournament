class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :tournaments, dependent: :nullify

  # Validations
  validates :role, inclusion: { in: %w[super_admin organizer] }
  validates :first_name, :last_name, presence: true

  # Role methods
  def super_admin?
    role == 'super_admin'
  end

  def organizer?
    role == 'organizer'
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
