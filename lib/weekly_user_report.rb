class WeeklyUserReport
  attr_reader :uid, :user_name, :email, :employee

  MILLISECONDS_PER_HOUR = 3_600_000
  DAILY_LIMIT_IN_MS = MILLISECONDS_PER_HOUR * 8

  def initialize(uid, user_name, email, employee, total_milliseconds)
    @uid = uid
    @user_name = user_name
    @email = email
    @employee = employee
    @total_milliseconds = total_milliseconds
  end

  def self.build_from_api(report_data, users_emails)
    uid = report_data['uid']
    new(
      uid,
      report_data['title']['user'],
      users_emails[uid][:email],
      users_emails[uid][:employee],
      report_data['totals']
    )
  end

  def total_hours
    milliseconds_to_hours(@total_milliseconds[7])
  end

  def day_hours(week_day)
    milliseconds_to_hours(@total_milliseconds[data_slot_index(week_day)])
  end

  def day_milliseconds(week_day)
    @total_milliseconds[data_slot_index(week_day)] || 0
  end

  def overtime_at?(week_day)
    overtime_milliseconds_at(week_day) > 0
  end

  def overtime_milliseconds_at(week_day)
    total_milliseconds = day_milliseconds_upto(week_day)
    maximum_milliseconds = week_day * DAILY_LIMIT_IN_MS
    [total_milliseconds - maximum_milliseconds, 0].max
  end

  private

  def day_milliseconds_upto(week_day)
    days_milliseconds = 1.upto(week_day).map { |week_day| day_milliseconds(week_day) }
    days_milliseconds.reduce(0, :+)
  end

  def data_slot_index(week_day)
    (week_day - 1) % 7
  end

  def milliseconds_to_hours(milliseconds)
    return 0.0 if milliseconds.nil?
    # Truncating instead of rounding (we don't want to 7h:59m:59s == 8 h)
    (milliseconds * 100 / MILLISECONDS_PER_HOUR.to_f).floor / 100.0
  end
end
