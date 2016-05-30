require 'weekly_user_report'
require 'monthly_user_reports_builder'

class TogglReportsClient
  DATA_API_URI = 'https://toggl.com/api/v8'
  REPORTS_API_URI = 'https://toggl.com/reports/api/v2'

  def initialize(token, company_name, debug = false)
    @token = token
    @debug = debug ? $stdout : nil
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

  def monthly_user_reports(year, month)
    return @monthly_users_report if defined?(@monthly_users_report)
    beggining_of_the_month = Date.new(year, month, 1)
    end_of_the_month = Date.new(year, month, -1)
    entries_data = daily_details(
        from: beggining_of_the_month,
        to: end_of_the_month,
      )['data']
    @monthly_users_report = MonthlyUserReportsBuilder.new.build(entries_data, users_data)
  end

  def detailed_daily_user_reports(date = Date.today)
    return @detailed_daily_user_reports if defined?(@detailed_daily_user_reports)
    first_response = daily_details(from: date, page: 1)
    time_entries = first_response['data']
    total_pages = calculate_pages(first_response)
    total_pages.times do |page|
      next if page == 0
      time_entries += daily_details(page: page + 1, from: date)['data']
    end
    @detailed_daily_user_reports = MonthlyUserReportsBuilder.new.build(time_entries, users_data)
  end

  private

  def calculate_pages(response)
    total = response['total_count']
    per_page = response['per_page']
    return 1 if total.nil? || per_page.nil?
    (total.to_f / per_page.to_f).ceil
  end

  def daily_details(from:, to: nil, page: 1)
    raise ArgumentError unless from.is_a? Date
    to = from if to.nil?
    query = {
      workspace_id: workspace['id'],
      page: page,
      since: from.strftime('%Y-%m-%d'),
      until: to.strftime('%Y-%m-%d')
    }
    HTTParty.get('/details', http_options(query: query))
  end

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
      query: { 'user_agent' => 'support@netguru.co' }.merge(query),
      basic_auth: { username: @token, password: 'api_token' },
      debug_output: @debug,
    }
  end
end
