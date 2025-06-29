defmodule Tracker.Goals.Goal do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger
  alias Tracker.Goals.GoalEntry

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "goals" do
    field :type, Ecto.Enum, values: [:numeric, :boolean], default: :boolean
    field :description, :string
    field :numeric_target, :integer

    has_many :entries, GoalEntry

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(goal, attrs) do
    goal
    |> cast(attrs, [:description])
    |> maybe_set_type_and_numeric_target()
    |> validate_required([:description, :type])
    |> unique_constraint(:description,
      name: "unique_goal_description",
      message: "You already have a goal with this description"
    )
    |> validate_boolean_type_has_no_target()
    |> validate_numeric_target_greater_than_0()
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

  defp validate_numeric_target_greater_than_0(changeset) do
    type = get_field(changeset, :type)

    if type == :numeric do
      validate_number(changeset, :numeric_target, greater_than: 0)
    else
      changeset
    end
  end

  defp maybe_set_type_and_numeric_target(changeset) do
    description = get_field(changeset, :description)

    if is_nil(description) do
      changeset
    else
      result = Regex.run(~r/\d+/, description)

      dbg(result)

      if is_nil(result) do
        changeset
        |> put_change(:type, :boolean)
        |> put_change(:numeric_target, nil)
      else
        number = List.first(result)

        dbg(number)

        case Integer.parse(number) do
          {int, _decimal} ->
            changeset
            |> put_change(:type, :numeric)
            |> put_change(:numeric_target, int)
            |> dbg()

          :error ->
            Logger.error("Incorrectly parsed #{number} as digits")

            changeset
        end
      end
    end
  end
end
