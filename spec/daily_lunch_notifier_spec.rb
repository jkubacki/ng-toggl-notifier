require 'daily_lunch_notifier'

describe DailyLunchNotifier do
  describe '#call' do
    let(:employee_flag) { true }
    let(:monthly_user_report) do
      MonthlyUserReport.new(
        '1',
        'John Doe',
        'john@doe.com',
        employee_flag,
        invalid_dinner_entries,
        [],
      )
    end
    let(:monthly_user_reports) { [monthly_user_report] }
    let(:daily_lunch_notifier) { described_class.new(monthly_user_reports) }

    context 'user has invalid dinner entries' do
      let(:invalid_dinner_entries) { [double("entry")] }

      it 'sends notification' do
        expect(Mailer)
          .to receive(:long_dinner)
          .with(monthly_user_report.email, report: monthly_user_report)
        daily_lunch_notifier.call
      end
    end

    context 'user has no invalid dinner entries' do
      let(:invalid_dinner_entries) { [] }

      it 'does not send notification' do
        expect(Mailer).not_to receive(:long_dinner)
        daily_lunch_notifier.call
      end
    end
  end
end
