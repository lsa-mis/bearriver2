class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  before_action :attach_logo

  private

  def attach_logo
    attachments.inline['U-M_Logo.svg'] = File.read(Rails.root.join('app/assets/images/U-M_Logo.svg'))
  end
end
