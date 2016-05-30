ENV['APP_ENV'] ||= 'development'

require 'bundler'
Bundler.require(:default, ENV['APP_ENV'])
$LOAD_PATH << File.join(__dir__, 'lib')

if %w(test development).include? ENV['APP_ENV']
  require 'letter_opener'
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

  if ENV['APP_ENV'] == 'development'
    Pony.options[:via] = LetterOpener::DeliveryMethod
    Pony.options[:via_options][:location] = File.expand_path('../tmp/letter_opener', __FILE__)
  end
end
