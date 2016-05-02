require 'monthly_user_report'

class MonthlyUserReportsBuilder
  DINNER_MAX_ENTRY_TIME_IN_MILISECONDS = 1_800_000 # 30 min
  private_constant :DINNER_MAX_ENTRY_TIME_IN_MILISECONDS

  def build(entries, users_emails)
    entries.each_with_object([]) do |entry, reports|
      next unless invalid_entry?(entry)
      uid = entry['uid']
      report = reports.find { |report| report.uid == uid }
      new_report = report.nil?
      report ||= MonthlyUserReport.new(
        uid,
        entry['user'],
        users_emails[uid][:email],
        users_emails[uid][:employee]
      )
      report.invalid_dinner_entries << entry if too_long_dinner?(entry)
      report.invalid_project_entries << entry if without_project?(entry)
      reports << report if new_report
    end
  end

  private

  def invalid_entry?(entry)
    without_project?(entry) || too_long_dinner?(entry)
  end

  def without_project?(entry)
    entry['pid'].nil?
  end

  def too_long_dinner?(entry)
    entry['project'].to_s.downcase == 'dinner' && entry['dur'] > DINNER_MAX_ENTRY_TIME_IN_MILISECONDS
  end
end
