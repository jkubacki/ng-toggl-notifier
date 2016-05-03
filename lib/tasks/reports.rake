require 'toggl_reports_client'
require 'daily_notifier'
require 'weekly_notifier'
require 'monthly_notifier'

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
  debugging_on = ENV['DEBUG'] == "true"
  report_client = TogglReportsClient.new(ENV['TOGGL_TOKEN'], ENV['COMPANY_NAME'], debugging_on)
  weekly_reports = report_client.weekly_user_reports
  DailyNotifier.new(weekly_reports, db).call
  puts "done."
end

desc "Monthly reports"
task :send_monthly, [:year, :month, :force] => :environment do |_, args|
  year = (args.year || Date.today.year).to_i
  month = (args.month || Date.today.month).to_i
  db = Sequel.connect(ENV['DATABASE_URL'])
  if !args.force && db[:executed_monthly].where(year: year, month: month).count > 0
    fail 'Monthly report already sent'
  end
  puts "Sending monthly..."
  debugging_on= ENV['DEBUG'] == "true"
  report_client = TogglReportsClient.new(ENV['TOGGL_TOKEN'], ENV['COMPANY_NAME'], debugging_on)
  monthly_reports = report_client.monthly_user_reports(year, month)
  MonthlyNotifier.new(monthly_reports, db).call
  db[:executed_monthly].insert(year: year, month: month)
  puts "done."
end
