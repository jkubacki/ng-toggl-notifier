require 'weekly_user_report'

class TogglReportsClient
  DATA_API_URI = 'https://toggl.com/api/v8'
  REPORTS_API_URI = 'https://toggl.com/reports/api/v2'

  def initialize(token, company_name)
    @token = token
    @company_name = company_name
  end

  def weekly_user_reports(previous_week = false)
    return @weekly_users_report if defined?(@weekly_users_report)
    monday = Date.today - (Date.today.wday - 1) % 7 - (previous_week ? 7 : 0)
    sunday = monday + 6
    query = {
      workspace_id: workspace['id'],
      grouping: 'users',
      since: monday.strftime('%Y-%m-%d'),
      until: sunday.strftime('%Y-%m-%d')
    }
    @weekly_users_report = HTTParty.get('/weekly', http_options(query: query))['data']
      .map { |ur| WeeklyUserReport.build_from_api(ur, users_data) }
  end

  private

  def workspace
    @workspace ||= HTTParty.get('/workspaces', http_options(data_api: true))
      .find { |w| w['name'] == @company_name }
  end

  def workspace_groups(workspace_id)
    @workspace_groups ||=
      HTTParty.get("/workspaces/#{workspace_id}/groups", http_options(data_api: true))
  end

  def employment_contract_group_id
    return @employment_contract_group_id if defined?(@employment_contract_group_id)
    groups = workspace_groups(workspace['id'])
    contract_group = groups.find { |g| g['name'].downcase == 'uop' }
    @employment_contract_group_id = contract_group.nil? ? nil : contract_group['id']
  end

  def users_data
    return @users_data if defined?(@users_data)
    @users_data = HTTParty
      .get("/workspaces/#{workspace['id']}/workspace_users", http_options(data_api: true))
      .each_with_object({}) do |wu, hash|
        hash[wu['uid']] = {
          email: wu['email'],
          employee: wu['group_ids'].include?(employment_contract_group_id)
        }
      end
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
