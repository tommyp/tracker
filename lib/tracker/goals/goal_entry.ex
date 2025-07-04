defmodule Tracker.Goals.GoalEntry do
  alias Tracker.Goals.Goal
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "goal_entries" do
    field :count, :integer
    field :date, :date
    field :completed, :boolean, default: false

    belongs_to :goal, Goal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(goal_entry, attrs) do
    goal_entry
    |> cast(attrs, [:count, :completed, :date])
    |> validate_required([:date])
    |> unique_constraint(:date,
      name: :unique_goal_entry_date_and_goal_id,
      message: "A goal can only have one entry per date"
    )
  end

  def count_changeset(goal_entry, attrs) do
    goal_entry
    |> cast(attrs, [:count])
    |> validate_number(:count, greater_than: 0)
  end
end
