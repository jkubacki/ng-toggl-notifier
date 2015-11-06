require 'toggl_reports_client'
require 'daily_notifier'
require 'weekly_notifier'

desc "Weekly reports"
task :send_weekly => :environment do
  if Date.today.monday?
    puts "Sending weekly..."
    report_client = TogglReportsClient.new(ENV['TOGGL_TOKEN'], ENV['COMPANY_NAME'])
    weekly_reports = report_client.weekly_user_reports
    WeeklyNotifier.new(weekly_reports).call
    puts "done."
  end
end

desc "Daily reports"
task :send_daily => :environment do
  puts "Sending daily..."
  report_client = TogglReportsClient.new(ENV['TOGGL_TOKEN'], ENV['COMPANY_NAME'])
  weekly_reports = report_client.weekly_user_reports
  DailyNotifier.new(weekly_reports).call
  puts "done."
end

