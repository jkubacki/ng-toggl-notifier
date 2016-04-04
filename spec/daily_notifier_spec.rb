require 'daily_notifier'

describe DailyNotifier do
  describe '#call' do
    let(:db) do
      db = double(:db)
      row = double(:row)
      allow(db).to receive(:[]).and_return(row)
      allow(row).to receive(:insert).and_return([])
      allow(row).to receive(:where).and_return([])
      db
    end
    let(:employee_flag) { true }
    let(:weekly_user_report) do
      WeeklyUserReport.new('1', 'John Doe', 'john@doe.com', employee_flag, input_time_struct)
    end
    let(:weekly_reports) { [weekly_user_report] }
    let(:daily_notifier) { described_class.new(weekly_reports, db) }

    let(:miliseconds_per_hour) { 3_600_000 }
    let(:eight_hours_in_ms) { 8 * miliseconds_per_hour }

    context 'on a business day' do
      let(:business_day) { Date.new(2015, 10, 28) }
      before { Timecop.freeze(business_day) }
      after { Timecop.return }

      let(:input_time_struct) do
        [nil, nil, worked_time_in_ms , nil, nil, nil, nil, worked_time_in_ms]
      end

      context 'user worked more than 8 hours' do
        let(:worked_time_in_ms) { eight_hours_in_ms + 1 }

        it 'sends business day notification' do
          expect(Mailer)
            .to receive(:daily_to_user)
            .with(weekly_user_report.email, report: weekly_user_report)
          daily_notifier.call
        end
      end

      context 'user worked exactly 8 hours' do
        let(:worked_time_in_ms) { eight_hours_in_ms }

        it 'does not send business day notification' do
          expect(Mailer)
            .not_to receive(:daily_to_user)
          daily_notifier.call
        end
      end

      context 'user worked less than 8 hours' do
        let(:worked_time_in_ms) { eight_hours_in_ms - 1 }

        it 'does not send bussiness day notification' do
          expect(Mailer)
            .not_to receive(:daily_to_user)
          daily_notifier.call
        end
      end
    end

    context 'at the weekend' do
      let(:weekend_day) { Date.new(2015, 10, 31) }
      before { Timecop.freeze(weekend_day) }
      after { Timecop.return }

      let(:input_time_struct) do
        [nil, nil, nil, nil, nil, worked_time_in_ms, nil, worked_time_in_ms]
      end

      context 'worked one hour' do
        let(:worked_time_in_ms) { miliseconds_per_hour }

        context 'and for employee' do
          it 'sends weekend notification' do
            expect(Mailer)
              .to receive(:weekend_day_to_user)
              .with(weekly_user_report.email, report: weekly_user_report)
            daily_notifier.call
          end
        end

        context 'and for contractor' do
          let(:employee_flag) { false }

          it 'sends weekend notification' do
            expect(Mailer)
              .not_to receive(:weekend_day_to_user)
            daily_notifier.call
          end
        end
      end

      context 'did not work' do
        let(:worked_time_in_ms) { 0 }

        context 'and for employee' do
          it 'does not send weekend notification' do
            expect(Mailer)
              .not_to receive(:weekend_day_to_user)
            daily_notifier.call
          end
        end
      end
    end
  end
end
