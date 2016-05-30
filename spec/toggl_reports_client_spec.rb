require 'toggl_reports_client'

describe TogglReportsClient do
  describe '#weekly_user_reports' do
    let(:client) { described_class.new('toggl_token', 'company_name', true) }

    before do
      allow(client).to receive(:workspace).and_return({ 'id' => 1 })
      Timecop.freeze(Date.new(2015, 10, 28))
    end

    after do
      Timecop.return
    end

    describe '#monthly_user_reports' do
      it 'passes proper parameters to http get query' do
        allow(client).to receive(:users_data)
        expect(HTTParty).to receive(:get).with('/details',
          {
            :base_uri=>"https://toggl.com/reports/api/v2",
            :query=> {
              "user_agent" =>"support@netguru.co",
              :workspace_id => 1,
              :page => 1,
              :since => "2015-10-01",
              :until => "2015-10-31"},
              :basic_auth => {:username=>"toggl_token", :password=>"api_token"
            },
            :debug_output => $stdout
          })
        .and_return({ 'data' => [] })

        client.monthly_user_reports(2015, 10)
      end
    end

    context 'current_week' do
      it 'passes proper paramters to http get query' do
        expect(HTTParty).to receive(:get).with('/weekly',
          {
            :base_uri=>"https://toggl.com/reports/api/v2",
            :query=> {
              "user_agent"=>"support@netguru.co",
              :workspace_id=>1,
              :grouping=>"users",
              :since=>"2015-10-26",
              :until=>"2015-11-01"},
              :basic_auth=>{:username=>"toggl_token", :password=>"api_token"
            },
            :debug_output => $stdout
          })
        .and_return({ 'data' => [] })

        client.weekly_user_reports()
      end
    end

    context 'previous week' do
      it 'passes proper paramters to http get query' do
        expect(HTTParty).to receive(:get).with('/weekly',
          {
            :base_uri=>"https://toggl.com/reports/api/v2",
            :query=> {
              "user_agent"=>"support@netguru.co",
              :workspace_id=>1,
              :grouping=>"users",
              :since=>"2015-10-19",
              :until=>"2015-10-25"},
              :basic_auth=>{:username=>"toggl_token", :password=>"api_token"
            },
            :debug_output => $stdout
          })
        .and_return({ 'data' => [] })

        client.weekly_user_reports(true)
      end
    end
  end
end
