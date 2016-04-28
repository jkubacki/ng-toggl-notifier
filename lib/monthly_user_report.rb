class MonthlyUserReport
  attr_reader :uid, :user_name, :email, :employee
  attr_accessor :invalid_dinner_entries, :invalid_project_entries

  def initialize(uid, user_name, email, employee)
    @uid = uid
    @user_name = user_name
    @email = email
    @employee = employee
    @invalid_dinner_entries = []
    @invalid_project_entries = []
  end

  def formatted_entries(entry_type)
    entries = entry_type == :dinner ? invalid_dinner_entries : invalid_project_entries
    entries.map do |entry|
      {
        start: format_date(entry['start']),
        end: format_date(entry['end']),
        duration: format_duration(entry['dur'])
      }
    end
  end

  private

  def format_date(date)
    Time.iso8601(date).strftime("%Y-%m-%d %H:%M:%S")
  end

  def format_duration(miliseconds)
    x = miliseconds / 1000
    seconds = x % 60
    x /= 60
    minutes = x % 60
    x /= 60
    hours = x % 24
    [hours, minutes, seconds].map { |e| e.to_s.rjust(2,'0') }.join ':'
  end
end
