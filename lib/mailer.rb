require 'erb'

class Mailer
  TEMPLATES_DIR = File.join(File.expand_path('..', __dir__), 'templates')

  def self.weekly_to_office(data = {})
    Pony.mail(
      to: ENV['OFFICE_EMAIL'],
      subject: 'Toggl weekly report',
      body: render(data)
    )
  end

  def self.daily_to_user(email, data = {})
    Pony.mail(
      to: email,
      subject: 'Toggl daily report',
      body: render(data)
    )
  end

  def self.weekend_day_to_user(email, data = {})
    Pony.mail(
      to: email,
      subject: 'Toggl weekend report',
      body: render(data)
    )
  end

  def self.monthly_to_user(email, data = {})
    Pony.mail(
      to: email,
      subject: 'Toggl monthly report',
      body: render(data)
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
