require 'weekly_user_report'

describe WeeklyUserReport do
  let(:weekly_user_report) do
    described_class.new(
      1,
      'John Doe',
      'john@doe.com',
      false,
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

  describe 'overtime calculation' do
    let(:weekly_user_report) do
      described_class.new(
        1,
        'John Doe',
        'john@doe.com',
        false,
        [
          working_day_ms - 1, # monday: no overtime
          working_day_ms + 1, # tuesday: no overtime
          working_day_ms + 1, # wednesday: overtime!!
          working_day_ms,   # thursday: still overtime!!
          working_day_ms - 2, # friday: no overtime
          0,
          nil,
          5 * working_day_ms - 1
        ]
      )

    end

    let(:working_day_ms) { WeeklyUserReport::DAILY_LIMIT_IN_MS }

    it 'returns no overtime on monday' do
      expect(weekly_user_report.overtime_at?(1)).to be(false)
      expect(weekly_user_report.overtime_milliseconds_at(1)).to be(0)
    end

    it 'returns no overtime on tuesday' do
      expect(weekly_user_report.overtime_at?(2)).to be(false)
      expect(weekly_user_report.overtime_milliseconds_at(2)).to be(0)
    end

    it 'returns overtime on wednesday' do
      expect(weekly_user_report.overtime_at?(3)).to be(true)
      expect(weekly_user_report.overtime_milliseconds_at(3)).to be(1)
    end

    it 'returns overtime on thursday' do
      expect(weekly_user_report.overtime_at?(4)).to be(true)
      expect(weekly_user_report.overtime_milliseconds_at(4)).to be(1)
    end

    it 'returns no overtime on friday' do
      expect(weekly_user_report.overtime_at?(5)).to be(false)
      expect(weekly_user_report.overtime_milliseconds_at(5)).to be(0)
    end
  end
end
