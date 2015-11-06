class WeeklyUserReport
  attr_reader :uid, :user_name, :email
  MILISECONDS_PER_HOUR = 3_600_000

  def initialize(uid, user_name, email, total_miliseconds)
    @uid = uid
    @user_name = user_name
    @email = email
    @total_miliseconds = total_miliseconds
  end

  def self.build_from_api(report_data, users_emails)
    uid = report_data['uid']
    new(
      uid,
      report_data['title']['user'],
      users_emails[uid],
      report_data['totals']
    )
  end

  def total_hours
    miliseconds_to_hours(@total_miliseconds[7])
  end

  def day_hours(week_day)
    data_slot = (week_day - 1) % 7
    miliseconds_to_hours(@total_miliseconds[data_slot])
  end

  private

  def miliseconds_to_hours(miliseconds)
    return 0.0 if miliseconds.nil?
    # Truncating instead of rounding (we don't want to 7h:59m:59s == 8 h)
    (miliseconds * 100 / MILISECONDS_PER_HOUR.to_f).floor / 100.0
  end
end
