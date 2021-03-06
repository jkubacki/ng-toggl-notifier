require 'erb'

class Mailer
  TEMPLATES_DIR = File.join(File.expand_path('..', __dir__), 'templates')

  def self.weekly_to_office(data = {})
    mail(ENV['OFFICE_EMAIL'], 'Toggl weekly report', render(data))
  end

  def self.daily_overtime_to_user(email, data = {})
    overtime_milliseconds = data.fetch(:overtime_milliseconds)
    overtime_seconds, overtime_milliseconds = overtime_milliseconds.divmod(1000)
    overtime_minutes, overtime_seconds = overtime_seconds.divmod(60)
    overtime_hours, overtime_minutes = overtime_minutes.divmod(60)
    mail(email, 'Toggl overtime report', render(data.merge(
      overtime_minutes: overtime_minutes,
      overtime_hours: overtime_hours
    )))
  end

  def self.weekend_day_to_user(email, data = {})
    mail(email, 'Toggl weekend report', render(data))
  end

  def self.empty_project(email, data = {})
    mail(email, 'You have empty project entry in Toggl', render(data))
  end

  def self.long_dinner(email, data = {})
    mail(email, 'You have long dinner entry in Toggl', render(data))
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
