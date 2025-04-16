class BalanceDueMailerPreview < ActionMailer::Preview
  def outstanding_balance
    application = Application.first || FactoryBot.build(:application)
    BalanceDueMailer.with(app: application).outstanding_balance
  end
end
