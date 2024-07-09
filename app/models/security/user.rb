# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  email                  :string
#  password_digest        :string
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  sign_in_count          :integer          default(0), not null
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  first_name             :string
#  last_name              :string
#  setup_completed_at     :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  # Validations
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ },
                    uniqueness: true

  validates :unconfirmed_email, length: { maximum: 255 },
                                format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ },
                                if: ->(obj) { obj.unconfirmed_email.present? }

  validates :password, length: { minimum: 4 },
                       if: ->(obj) { obj.new_record? || obj.password.present? }

  # Callbacks
  after_create :create_default_organization
  after_create :send_new_user_instructions
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to ->(user) { [user] }, inserts_by: :prepend, partial: 'settings/users/user'

  #
  # Shorthands
  #

  def avatar_url
    "//www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=identicon"
  end

  def display_name
    [first_name, last_name].join(' ')
  end

  #
  # Confirmation
  #

  def confirm!
    return false if confirmed?

    if unconfirmed_email.present?
      update(
        confirmed_at: Time.zone.now,
        email: unconfirmed_email,
        unconfirmed_email: nil
      )
    elsif confirmed_at.blank?
      update(
        confirmed_at: Time.zone.now
      )
    end
  end

  def confirmed?
    confirmed_at.present? && unconfirmed_email.blank?
  end

  #
  # Password
  #

  def can_update_password?(current_password)
    return false unless authenticate(current_password)

    true
  end

  def send_reset_password_instructions!
    update(
      reset_password_sent_at: Time.zone.now,
      reset_password_token: SecureRandom.urlsafe_base64
    )

    UserMailer.new_password(id).deliver_later
  end

  #
  # Email
  #

  def cancel_change_email!
    update(
      unconfirmed_email: nil,
      confirmation_sent_at: Time.zone.now
    )
  end

  def change_email!(new_email)
    update(
      unconfirmed_email: new_email,
      confirmation_sent_at: Time.zone.now,
      confirmation_token: SecureRandom.urlsafe_base64
    ) && UserMailer.change_email(id).deliver_later
  end

  #
  # Organizations
  #

  def all_organizations
    organizations.joins(:memberships)
                 .includes(:memberships)
                 .where("memberships.level IN ('member', 'owner', 'admin')")
                 .order(:name)
  end

  def managed_organizations
    organizations.joins(:memberships)
                 .includes(:memberships)
                 .where("memberships.level IN ('owner', 'admin')")
                 .order(:name)
  end

  def owned_organizations
    organizations.joins(:memberships)
                 .includes(:memberships)
                 .where("memberships.level IN ('owner')")
                 .order(:name)
  end

  def current_organization
    organizations
      .joins(:memberships)
      .order(Arel.sql('COALESCE(memberships.last_logged_in_at, \'1900-01-01\') DESC, COALESCE(memberships.created_at, \'1900-01-01\') ASC')).first
  end

  def current_organization!(organization)
    memberships.where(organization:).update(
      last_logged_in_at: Time.zone.now
    )
  end

  #
  # Class methods
  #

  def self.authenticate_with_email_and_password(email, password, sign_in_ip)
    user = User.find_by(email:)
    return unless user&.authenticate(password)

    user.update(
      sign_in_count: user.sign_in_count + 1,
      current_sign_in_ip: sign_in_ip,
      current_sign_in_at: Time.zone.now,
      last_sign_in_at: user.current_sign_in_at,
      last_sign_in_ip: user.last_sign_in_ip
    )

    user
  end

  def self.reset_password_with_token!(token, password)
    user = User.find_by(reset_password_token: token)

    return false unless user&.update(
      password:,
      reset_password_sent_at: nil,
      reset_password_token: nil
    )

    user
  end

  def self.find_or_create_with_random_password(email)
    user = User.find_by(email:)
    return user if user.present?

    user = User.create(
      email:,
      password: SecureRandom.urlsafe_base64,
      confirmation_sent_at: Time.zone.now,
      confirmation_token: SecureRandom.urlsafe_base64,
      reset_password_sent_at: Time.zone.now,
      reset_password_token: SecureRandom.urlsafe_base64
    )

    UserMailer.invited_user(user.id).deliver_later

    user
  end

  private

  def create_default_organization
    return if organizations.size.positive?

    organizations.create(name: 'Default organization')
    organizations.first.define_owner!(self)
  end

  def send_new_user_instructions
    update(
      confirmation_sent_at: Time.zone.now,
      confirmation_token: SecureRandom.urlsafe_base64
    )

    UserMailer.new_user(id).deliver_later
  end

  def can_update?
    true
  end

  def can_delete?
    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
