require 'mailer'

describe Mailer do

  let(:mailer) { described_class }

  before do
    Pony.override_options = { via: :test, charset: 'utf8' }
  end

  describe '.daily_overtime_to_user' do

    let(:action) { mailer.daily_overtime_to_user('john@example.com', overtime_milliseconds: 2.5*3600*1000 + 5001) }
    let(:email) {
      action
      Mail::TestMailer.deliveries.last
    }

    it 'sends an email' do
      expect { action }.to change { Mail::TestMailer.deliveries.length }.by(1)
    end

    it 'sends an email to correct address' do
      expect(email.to).to eq(['john@example.com'])
    end

    it 'sends an email including overtime information' do
      expect(email.body).to include('2 godzin i 30 minut')
      expect(email.body).to include('2 hours and 30 minutes')
    end
  end
end
