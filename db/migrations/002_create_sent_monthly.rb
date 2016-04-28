Sequel.migration do
  up do
    create_table(:sent_monthly) do
      primary_key :id
      String :email, null: false
      Date :sent_at, null: false
    end
  end

  down do
    drop_table(:sent_monthly)
  end
end
