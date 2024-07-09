# frozen_string_literal: true

class UserMailer < ApplicationMailer
  layout 'user_mailer/layouts/default'

  def new_user(user_id)
    @user = User.find(user_id)

    mail(to: @user.email,
         subject: 'Welcome to Ninetyfour!',
         date: Time.zone.now,
         template_path: 'user_mailer',
         template_name: 'new_user')
  end

  def invited_user(user_id)
    @user = User.find(user_id)

    mail(to: @user.email,
         subject: 'You have been invited to join your organization on Ninetyfour!',
         date: Time.zone.now,
         template_path: 'user_mailer',
         template_name: 'invited_user')
  end

  def new_password(user_id)
    @user = User.find(user_id)

    mail(to: @user.email,
         subject: 'Ninetyfour: Forgot password?',
         date: Time.zone.now,
         template_path: 'user_mailer',
         template_name: 'new_password')
  end

  def change_email(user_id)
    @user = User.find(user_id)

    mail(to: @user.unconfirmed_email,
         subject: 'Ninetyfour: Change email request',
         date: Time.zone.now,
         template_path: 'user_mailer',
         template_name: 'change_email')
  end
end
