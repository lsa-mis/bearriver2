class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = User.first || FactoryBot.build(:user)
    token = 'fake-reset-token'
    Devise::Mailer.reset_password_instructions(user, token)
  end
end
