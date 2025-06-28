defmodule Tracker.Goals.Goal do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "goals" do
    field :type, Ecto.Enum, values: [:numeric, :boolean]
    field :description, :string
    field :numeric_target, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(goal, attrs) do
    goal
    |> cast(attrs, [:description, :type, :numeric_target])
    |> validate_required([:description, :type])
  end
end
