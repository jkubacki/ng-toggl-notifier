require 'daily_invalid_project_notifier'

describe DailyInvalidProjectNotifier do
  describe '#call' do
    let(:employee_flag) { true }
    let(:monthly_user_report) do
      MonthlyUserReport.new(
        '1',
        'John Doe',
        'john@doe.com',
        employee_flag,
        [],
        invalid_project_entries,
      )
    end
    let(:monthly_user_reports) { [monthly_user_report] }
    let(:daily_invalid_project_notifier) { described_class.new(monthly_user_reports) }

    context 'user has invalid dinner entries' do
      let(:invalid_project_entries) { [double("entry")] }

      it 'sends notification' do
        expect(Mailer)
          .to receive(:empty_project)
          .with(monthly_user_report.email, report: monthly_user_report)
        daily_invalid_project_notifier.call
      end
    end

    context 'user has no invalid dinner entries' do
      let(:invalid_project_entries) { [] }

      it 'does not send notification' do
        expect(Mailer).not_to receive(:empty_project)
        daily_invalid_project_notifier.call
      end
    end
  end
end
