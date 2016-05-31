require 'user_invalidity_reports_builder'

describe UserInvalidityReportsBuilder do
  let(:user_emails) do
    {
      1 => { email: "user@example.com", employee: true },
      2 => { email: "user2@example.com", employee: true },
      3 => { email: "user3@example.com", employee: true }
    }
  end
  let(:dinner_valid)    { {"pid" => 1, "uid" => 1, "project" => "dinner", "dur" => 1, "user" => 'user'} }
  let(:dinner_invalid)  { {"pid" => 1, "uid" => 1, "project" => "dinner", "dur" => 1_800_001, "user" => 'user'} }
  let(:project_valid)   { {"pid" => 1, "uid" => 1, "project" => "project", "dur" => 1, "user" => 'user'} }
  let(:project_invalid) { {"pid" => nil, "uid" => 1, "project" => nil, "dur" => 1, "user" => 'user'} }
  let(:project_invalid_user2) { {"pid" => nil, "uid" => 2, "project" => nil, "dur" => 1, "user" => 'user'} }

  subject { described_class.new.build(entries, user_emails) }

  let(:entries) { [dinner_valid, dinner_invalid, project_valid, project_invalid, project_invalid_user2] }

  it 'returns as many reports as users with invalid projects' do
    expect(subject.count).to eq 2
  end

  it 'assigns invalid dinner entries to users' do
    expect(subject.first.invalid_dinner_entries).to eq [dinner_invalid]
    expect(subject.last.invalid_dinner_entries).to eq []
  end

  it 'assigns invalid project entries to users' do
    expect(subject.first.invalid_project_entries).to eq [project_invalid]
    expect(subject.last.invalid_project_entries).to eq [project_invalid_user2]
  end

  it 'assigns user email to report' do
    expect(subject.first.email).to eq 'user@example.com'
  end

  it 'assigns user employee status to report' do
    expect(subject.first.employee).to eq true
  end

  it 'assigns entry username to report' do
    expect(subject.first.user_name).to eq 'user'
  end

  context 'all entries are valid' do
    let(:entries) { [dinner_valid, project_valid] }

    it 'returns no reports' do
      expect(subject).to eq []
    end
  end
end
