require 'pstore'
require 'mailer'
require 'weekly_user_report'

class DailyNotifier
  STORE = File.join(File.expand_path('..', __dir__), 'store', 'daily.pstore')

  def initialize(weekly_reports, db)
    @weekly_reports = weekly_reports
    @db = db
  end

  def self.call(weekly_reports)
    new(weekly_reports).call
  end

  def call
    today = Date.today
    week_day = today.wday
    weekly_reports.each do |report|
      if today.saturday? || today.sunday?
        weekend_day_notification(report) if send_weekend_day_notification?(week_day, report)
      else
        overtime_notification(week_day, report) if send_overtime_notification?(week_day, report)
      end
    end
  end

  private

  attr_reader :weekly_reports

  def weekend_day_notification(report)
    Mailer.weekend_day_to_user(report.email, report: report)
    store_notification(report.email)
  end

  def overtime_notification(week_day, report)
    Mailer.daily_overtime_to_user(report.email, week_day: week_day, overtime_milliseconds: report.overtime_milliseconds_at(week_day))
    store_notification(report.email)
  end

  def send_weekend_day_notification?(week_day, report)
    report.employee && report.day_hours(week_day) > 0 && last_sent(report.email) < Date.today
  end

  def send_overtime_notification?(week_day, report)
    report.overtime_at?(week_day) && last_sent(report.email) < Date.today
  end

  def store_notification(email)
    sent_daily = @db[:sent_daily]
    sent = sent_daily.where(email: email)
    if sent.first
      sent.update(sent_at: Date.today)
    else
      sent_daily.insert(email: email, sent_at: Date.today)
    end
  end

  def last_sent(email)
    sent_daily = @db[:sent_daily]
    sent = sent_daily.where(email: email).first
    sent.nil? ? Date.new : sent[:sent_at]
  end
end
