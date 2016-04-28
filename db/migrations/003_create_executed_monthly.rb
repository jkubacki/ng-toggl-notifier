Sequel.migration do
  up do
    create_table(:executed_monthly) do
      primary_key :id
      Integer :year, null: false
      Integer :month, null: false
    end
  end

  down do
    drop_table(:executed_monthly)
  end
end
