require 'daily_notifier'

describe DailyNotifier do
  after do
    File.delete DailyNotifier::STORE if File.exist?(DailyNotifier::STORE)
  end

  describe '#call' do
    let(:daily_notifier) { described_class.new(weekly_reports) }
    let(:weekly_user_report) do
      WeeklyUserReport.new('1', 'John Doe', 'john@doe.com', working_time)
    end
    let(:weekly_reports) { [weekly_user_report] }

    context 'user worked more than 8 hours in a business day' do
      let(:working_time) { [nil, nil, 28_800_000, nil, nil, nil, nil, 28_800_000] }

      it 'sends business day notification' do
        allow(Date).to receive(:today) { Date.new(2015, 10, 28) }
        expect(daily_notifier).to receive(:business_day_notification)
        daily_notifier.call
      end
    end

    context 'user worked less than 8 hours in a business day' do
      let(:working_time) { [nil, nil, 28_799_999, nil, nil, nil, nil, 28_799_999] }

      it 'does not send bussiness day notification' do
        allow(Date).to receive(:today) { Date.new(2015, 10, 28) }
        expect(daily_notifier).not_to receive(:business_day_notification)
        daily_notifier.call
      end
    end

    context 'user worked more than 1 hour in a weekend day' do
      let(:working_time) { [nil, nil, nil, nil, nil, 3_600_000, nil, 3_600_000] }

      it 'sends weekend notification on saturday' do
        allow(Date).to receive(:today) { Date.new(2015, 10, 31) }
        expect(daily_notifier).to receive(:weekend_day_notification)
        daily_notifier.call
      end
    end

    context 'user worked less than 1 hour in a weekend day' do
      let(:working_time) { [nil, nil, nil, nil, nil, nil, 3_599_999, 3_599_999] }

      it 'does not send weekend notification on sunday' do
        allow(Date).to receive(:today) { Date.new(2015, 11, 1) }
        expect(daily_notifier).not_to receive(:weekend_day_notification)
        daily_notifier.call
      end
    end
  end
end
