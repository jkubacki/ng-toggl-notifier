ENV['APP_ENV'] ||= 'development'

require 'bundler'
Bundler.require(:default, ENV['APP_ENV'])
$LOAD_PATH << File.join(__dir__, 'lib')

if %w(test development).include? ENV['APP_ENV']
  require 'dotenv'
  Dotenv.load
end

Rake.add_rakelib 'lib/tasks'

task :environment do
  Pony.options = {
    :from => ENV['OFFICE_EMAIL'],
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  }
end
