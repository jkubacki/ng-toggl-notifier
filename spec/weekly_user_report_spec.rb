require 'weekly_user_report'

describe WeeklyUserReport do
  let(:weekly_user_report) do
    described_class.new(
      1,
      'John Doe',
      'john@doe.com',
      [nil, 28_800_000, 28_800_000, 14_400_000, nil, nil, 14_400_000, 86_400_000])
  end

  describe '#total_hours' do
    it 'returns total hours in a week' do
      expect(weekly_user_report.total_hours).to eq(24)
    end
  end

  describe '#hours' do
    it 'returns hours in a given week day' do
      expect(weekly_user_report.day_hours(0)).to eq(4)
      expect(weekly_user_report.day_hours(1)).to eq(0)
      expect(weekly_user_report.day_hours(2)).to eq(8)
      expect(weekly_user_report.day_hours(3)).to eq(8)
      expect(weekly_user_report.day_hours(4)).to eq(4)
      expect(weekly_user_report.day_hours(5)).to eq(0)
      expect(weekly_user_report.day_hours(6)).to eq(0)
    end
  end
end
