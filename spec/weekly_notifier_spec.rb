require 'weekly_notifier'
# require 'timecop'
require 'mailer'

describe WeeklyNotifier do
  describe '#call' do
    before do
      Timecop.freeze(Time.local(2015, 11, 9, 6, 0, 0))
    end

    after do
      Timecop.return
    end

    let(:weekly_user_report) do
      WeeklyUserReport.new('1', 'John Doe', 'john@doe.com', false, working_time)
    end
    let(:weekly_reports) { [weekly_user_report] }
    let(:weekly_notifier) { described_class.new(weekly_reports) }

    context 'user worked more than 40 hours' do
      let(:working_time) do
        [28_800_000, 28_800_000, 28_800_000, 28_800_000, 28_900_000, nil, nil, 145_100_000]
      end

      it 'sends weekly notification' do
        expect(Mailer).to receive(:weekly_to_office).with(reports: weekly_reports)
        weekly_notifier.call
      end
    end

    context 'user worked less than 40 hours' do
      let(:working_time) do
        [28_800_000, 28_800_000, 28_800_000, 28_800_000, 28_799_999, nil, nil, 143_999_999]
      end

      it 'sends weekly notification' do
        expect(Mailer).not_to receive(:weekly_to_office)
        weekly_notifier.call
      end
    end
  end
end
