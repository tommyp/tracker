defmodule Tracker.Repo.Migrations.CreateGoals do
  use Ecto.Migration

  def change do
    create table(:goals, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string
      add :type, :string
      add :numeric_target, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
