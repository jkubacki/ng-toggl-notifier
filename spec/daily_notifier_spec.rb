require 'daily_notifier'

describe DailyNotifier do
  describe '#call' do
    let(:db) do
      db = double(:db)
      row = double(:row)
      allow(db).to receive(:[]).and_return(row)
      allow(row).to receive(:where).and_return([])
      db
    end
    let(:daily_notifier) { described_class.new(weekly_reports, db) }
    let(:weekly_user_report) do
      WeeklyUserReport.new('1', 'John Doe', 'john@doe.com', true, working_time)
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

    context 'work at the weekend' do
      let(:working_time) { [nil, nil, nil, nil, nil, 3_600_000, nil, 3_600_000] }
      context 'employee' do
        it 'sends weekend notification' do
          allow(Date).to receive(:today) { Date.new(2015, 10, 31) }
          expect(daily_notifier).to receive(:weekend_day_notification)
          daily_notifier.call
        end
      end

      context 'contractor' do
        let(:weekly_user_report) do
          WeeklyUserReport.new('1', 'John Doe', 'john@doe.com', false, working_time)
        end

        it 'sends weekend notification' do
          allow(Date).to receive(:today) { Date.new(2015, 10, 31) }
          expect(daily_notifier).not_to receive(:weekend_day_notification)
          daily_notifier.call
        end
      end
    end

    context 'employee did not work at the weekend' do
      let(:working_time) { [nil, nil, nil, nil, nil, 0, nil, 0] }
      context 'employee' do
        it 'does not send weekend notification' do
          allow(Date).to receive(:today) { Date.new(2015, 10, 31) }
          expect(daily_notifier).not_to receive(:weekend_day_notification)
          daily_notifier.call
        end
      end
    end
  end
end
