defmodule Tracker.Repo.Migrations.AddUniqueIndexForGoalDescription do
  use Ecto.Migration

  def change do
    create unique_index(:goals, [:description], name: :unique_goal_description)
  end
end
