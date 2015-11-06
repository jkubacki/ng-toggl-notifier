Sequel.migration do
  up do
    create_table(:sent_daily) do
      primary_key :id
      String :email, null: false, unique: true
      Date :sent_at, null: false
    end
  end

  down do
    drop_table(:sent_daily)
  end
end
