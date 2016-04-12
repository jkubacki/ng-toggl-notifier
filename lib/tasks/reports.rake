require 'toggl_reports_client'
require 'daily_notifier'
require 'weekly_notifier'

desc "Weekly reports"
task :send_weekly => :environment do
  if Date.today.monday? || ENV['SEND_WEEKLY_EVERY_DAY'] == 'true'
    puts "Sending weekly..."
    debugging_on= ENV['DEBUG'] == "true"
    report_client = TogglReportsClient.new(ENV['TOGGL_TOKEN'], ENV['COMPANY_NAME'], debugging_on)
    weekly_reports = report_client.weekly_user_reports(true)
    WeeklyNotifier.new(weekly_reports).call
    puts "done."
  end
end

desc "Daily reports"
task :send_daily => :environment do
  puts "Sending daily..."
  db = Sequel.connect(ENV['DATABASE_URL'])
  debugging_on= ENV['DEBUG'] == "true"
  report_client = TogglReportsClient.new(ENV['TOGGL_TOKEN'], ENV['COMPANY_NAME'], debugging_on)
  weekly_reports = report_client.weekly_user_reports
  DailyNotifier.new(weekly_reports, db).call
  puts "done."
end

