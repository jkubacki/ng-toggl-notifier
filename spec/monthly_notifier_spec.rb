require 'monthly_notifier'

describe MonthlyNotifier do
  let(:entry) { {'start' => '2016-01-01T17:30:10+02:00', 'end' => '2016-01-01T19:30:10+02:00', 'dur' => 3666600} }

  let(:first_report) { MonthlyUserReport.new(1, 'user_name', 'email@example.com', 'employee', [entry]) }
  let(:second_report) { MonthlyUserReport.new(1, 'user_name', 'email2@example.com', 'employee', [entry]) }
  let(:monthly_reports) { [first_report, second_report] }
  let(:db) do
    db = double(:db)
    row = double(:row)
    allow(db).to receive(:[]).and_return(row)
    allow(row).to receive(:insert).and_return([])
    db
  end
  subject { described_class.new(monthly_reports, db) }

  it 'sends monthly notification for each report' do
    expect(Mailer).to receive(:monthly_to_user).with('email@example.com', report: first_report)
    expect(Mailer).to receive(:monthly_to_user).with('email2@example.com', report: second_report)
    subject.call
  end
end
