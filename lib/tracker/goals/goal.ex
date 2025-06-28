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
    |> validate_boolean_type_has_no_target()
  end

  defp validate_boolean_type_has_no_target(changeset) do
    type = get_field(changeset, :type)

    if type == :boolean do
      target = get_field(changeset, :numeric_target)

      if is_nil(target) do
        changeset
      else
        add_error(changeset, :type, "A boolean goal cannot have a target")
      end
    else
      changeset
    end
  end
end
