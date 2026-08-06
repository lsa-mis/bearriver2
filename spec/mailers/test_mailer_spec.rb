# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestMailer, type: :mailer do
  it 'sends a configuration test email' do
    mail = described_class.test_email('ops@example.com')

    expect(mail.to).to eq(['ops@example.com'])
    expect(mail.subject).to eq('Test Email from LSA Evaluate')
    expect(mail.body.encoded).to include('verify email configuration')
  end

  it 'defaults the recipient when none is provided' do
    mail = described_class.test_email
    expect(mail.to).to eq(['lsa-wads-rails-email-test@umich.edu'])
  end
end
