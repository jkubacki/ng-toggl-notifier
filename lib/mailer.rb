require 'erb'

class Mailer
  TEMPLATES_DIR = File.join(File.expand_path('..', __dir__), 'templates')

  def self.weekly_to_office(data = {})
    mail(ENV['OFFICE_EMAIL'], 'Toggl weekly report', render(data))
  end

  def self.daily_to_user(email, data = {})
    mail(email, 'Toggl daily report', render(data))
  end

  def self.weekend_day_to_user(email, data = {})
    mail(email, 'Toggl weekend report', render(data))
  end

  def self.monthly_to_user(email, data = {})
    mail(email, 'Toggl monthly report', render(data))
  end

  def self.mail(email, subject, data)
    email_to = ENV['TEST_EMAIL'] || email
    Pony.mail(
      to: email_to,
      subject: subject,
      body: data
    )
  end

  def self.render(data = {})
    template_name = caller[0][/`.*'/][1..-2]
    template_path = File.join(TEMPLATES_DIR, "#{template_name}.txt")
    unless File.exist?(template_path)
      raise StandardError, "Template #{template_path} does not exist."
    end
    template = File.read(template_path)
    context = OpenStruct.new(data)
    ERB.new(template).result(context.instance_eval { binding } )
  end

  private_class_method :render
end
