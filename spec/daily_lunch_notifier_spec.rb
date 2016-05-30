require 'daily_lunch_notifier'

describe DailyLunchNotifier do
  describe '#call' do
    let(:employee_flag) { true }
    let(:invalidity_report) do
      UserInvalidityReport.new(
        '1',
        'John Doe',
        'john@doe.com',
        employee_flag,
        invalid_dinner_entries,
        [],
      )
    end
    let(:invalidity_reports) { [invalidity_report] }
    let(:daily_lunch_notifier) { described_class.new(invalidity_reports) }

    context 'user has invalid dinner entries' do
      let(:invalid_dinner_entries) { [double("entry")] }

      it 'sends notification' do
        expect(Mailer)
          .to receive(:long_dinner)
          .with(invalidity_report.email, report: invalidity_report)
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
