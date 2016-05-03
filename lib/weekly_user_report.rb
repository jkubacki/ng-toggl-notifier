class WeeklyUserReport
  attr_reader :uid, :user_name, :email, :employee
  MILISECONDS_PER_HOUR = 3_600_000

  def initialize(uid, user_name, email, employee, total_miliseconds)
    @uid = uid
    @user_name = user_name
    @email = email
    @employee = employee
    @total_miliseconds = total_miliseconds
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
    miliseconds_to_hours(@total_miliseconds[7])
  end

  def day_hours(week_day)
    miliseconds_to_hours(@total_miliseconds[data_slot_index(week_day)])
  end

  def day_miliseconds(week_day)
    @total_miliseconds[data_slot_index(week_day)] || 0
  end

  private

  def data_slot_index(week_day)
    (week_day - 1) % 7
  end

  def miliseconds_to_hours(miliseconds)
    return 0.0 if miliseconds.nil?
    # Truncating instead of rounding (we don't want to 7h:59m:59s == 8 h)
    (miliseconds * 100 / MILISECONDS_PER_HOUR.to_f).floor / 100.0
  end
end
