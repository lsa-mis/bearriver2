class AppConfirmationMailerPreview < ActionMailer::Preview
  def application_submitted
    application = Application.first || FactoryBot.build(:application)
    AppConfirmationMailer.with(app: application).application_submitted
  end
end
