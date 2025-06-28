defmodule Tracker.Repo.Migrations.CreateGoalEntries do
  use Ecto.Migration

  def change do
    create table(:goal_entries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :count, :integer
      add :completed, :boolean, default: false, null: false
      add :date, :date
      add :goal_id, references(:goals, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:goal_entries, [:goal_id])
  end
end
