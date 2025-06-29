defmodule Tracker.Repo.Migrations.AddUniqueIndexForGoalEntryDateAndGoalId do
  use Ecto.Migration

  def change do
    create unique_index(:goal_entries, [:date, :goal_id],
             name: :unique_goal_entry_date_and_goal_id
           )
  end
end
