class UserInvalidityReport
  attr_reader :uid, :user_name, :email, :employee
  attr_accessor :invalid_dinner_entries, :invalid_project_entries

  def initialize(uid, user_name, email, employee, invalid_dinner_entries = [], invalid_project_entries = [])
    @uid = uid
    @user_name = user_name
    @email = email
    @employee = employee
    @invalid_dinner_entries = invalid_dinner_entries
    @invalid_project_entries = invalid_project_entries
  end
end
