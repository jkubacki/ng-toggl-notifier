require 'monthly_user_report'

describe MonthlyUserReport do
  let(:entry) { {'start' => '2016-01-01T17:30:10+02:00', 'end' => '2016-01-01T19:30:10+02:00', 'dur' => 3666600} }
  let(:report) { described_class.new(1, 'user_name', 'email@example.com', 'employee') }

  before { report.invalid_dinner_entries << entry }

  subject { report.formatted_entries(:dinner) }

  describe '#formatted_entries' do
    it 'formats start date correctly' do
      expect(subject.first[:start]).to eq '2016-01-01 17:30:10'
    end

    it 'formats end date correctly' do
      expect(subject.first[:end]).to eq '2016-01-01 19:30:10'
    end

    it 'formats duration time correctly' do
      expect(subject.first[:duration]).to eq '01:01:06'
    end
  end
end
