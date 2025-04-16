class LotteryMailerPreview < ActionMailer::Preview
  def won_lottery_email
    application = Application.first || FactoryBot.build(:application)
    LotteryMailer.with(application: application).won_lottery_email
  end

  def pre_lottery_offer_email
    application = Application.first || FactoryBot.build(:application)
    LotteryMailer.with(application: application).pre_lottery_offer_email
  end

  def waitlisted_offer_email
    application = Application.first || FactoryBot.build(:application)
    LotteryMailer.with(application: application).waitlisted_offer_email
  end

  def lost_lottery_email
    application = Application.first || FactoryBot.build(:application)
    LotteryMailer.with(application: application).lost_lottery_email
  end
end
