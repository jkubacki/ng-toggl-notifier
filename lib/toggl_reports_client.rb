require 'weekly_user_report'

class TogglReportsClient
  DATA_API_URI = 'https://toggl.com/api/v8'
  REPORTS_API_URI = 'https://toggl.com/reports/api/v2'

  def initialize(token, company_name)
    @token = token
    @company_name = company_name
  end

  def weekly_user_reports
    return @weekly_users_report if defined?(@weekly_users_report)
    monday = Date.today - (Date.today.wday - 1) % 7
    sunday = monday + 6
    query = {
      workspace_id: workspace['id'],
      grouping: 'users',
      since: monday.strftime('%Y-%m-%d'),
      until: sunday.strftime('%Y-%m-%d')
    }
    @weekly_users_report = HTTParty.get('/weekly', http_options(query: query))['data']
      .map { |ur| WeeklyUserReport.build_from_api(ur, users_emails) }
  end

  private

  def workspace
    @workspace ||= HTTParty.get('/workspaces', http_options(data_api: true))
      .find { |w| w['name'] == @company_name }
  end

  def users_emails
    return @users_emails if defined?(@users_emails)
    @users_emails = HTTParty
      .get("/workspaces/#{workspace['id']}/workspace_users", http_options(data_api: true))
      .each_with_object({}) { |wu, hash| hash[wu['uid']] = wu['email'] }
  end

  def http_options(query: {}, data_api: false)
    {
      base_uri: data_api ? DATA_API_URI : REPORTS_API_URI,
      query: { 'user_agent' => 'jacek.adamek@netguru.co' }.merge(query),
      basic_auth: { username: @token, password: 'api_token' },
      debug_output: $stdout
    }
  end
end
