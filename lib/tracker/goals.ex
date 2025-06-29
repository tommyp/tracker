defmodule Tracker.Goals do
  @moduledoc """
  The Goals context.
  """

  import Ecto.Query, warn: false
  alias Tracker.Repo

  alias Tracker.Goals.Goal
  alias Tracker.Goals.GoalEntry

  @doc """
  Returns the list of goals.

  ## Examples

      iex> list_goals()
      [%Goal{}, ...]

  """
  def list_goals do
    Repo.all(Goal)
  end

  @doc """
  Return a list of goals and the entry for a given date

  ## Examples

      iex> list_goals_with_entries_for_date()
      [{%Goal{}, %GoalEntry{}}]
  """
  def list_goals_with_entries_for_date(date) do
    from(
      g in Goal,
      left_join: ge in GoalEntry,
      on: ge.goal_id == g.id and ge.date == ^date,
      select: {g, ge}
    )
    |> Repo.all()
  end

  @doc """
  Gets a single goal.

  Raises `Ecto.NoResultsError` if the Goal does not exist.

  ## Examples

      iex> get_goal!(123)
      %Goal{}

      iex> get_goal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_goal!(id), do: Repo.get!(Goal, id)

  @doc """
  Creates a goal.

  ## Examples

      iex> create_goal(%{field: value})
      {:ok, %Goal{}}

      iex> create_goal(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_goal(attrs \\ %{}) do
    %Goal{}
    |> Goal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a goal.

  ## Examples

      iex> update_goal(goal, %{field: new_value})
      {:ok, %Goal{}}

      iex> update_goal(goal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_goal(%Goal{} = goal, attrs) do
    goal
    |> Goal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a goal.

  ## Examples

      iex> delete_goal(goal)
      {:ok, %Goal{}}

      iex> delete_goal(goal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_goal(%Goal{} = goal) do
    Repo.delete(goal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking goal changes.

  ## Examples

      iex> change_goal(goal)
      %Ecto.Changeset{data: %Goal{}}

  """
  def change_goal(%Goal{} = goal, attrs \\ %{}) do
    Goal.changeset(goal, attrs)
  end

  alias Tracker.Goals.GoalEntry

  @doc """
  Returns the list of goal_entries.

  ## Examples

      iex> list_goal_entries()
      [%GoalEntry{}, ...]

  """
  def list_goal_entries do
    Repo.all(GoalEntry)
  end

  @doc """
  Gets a single goal_entry.

  Raises `Ecto.NoResultsError` if the Goal entry does not exist.

  ## Examples

      iex> get_goal_entry!(123)
      %GoalEntry{}

      iex> get_goal_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_goal_entry!(id), do: Repo.get!(GoalEntry, id)

  @doc """
  Creates a goal_entry.

  ## Examples

      iex> create_goal_entry(%{field: value})
      {:ok, %GoalEntry{}}

      iex> create_goal_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_goal_entry(%Goal{} = goal, attrs \\ %{}) do
    %GoalEntry{
      goal_id: goal.id
    }
    |> GoalEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a goal_entry.

  ## Examples

      iex> update_goal_entry(goal_entry, %{field: new_value})
      {:ok, %GoalEntry{}}

      iex> update_goal_entry(goal_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_goal_entry(%GoalEntry{} = goal_entry, attrs) do
    goal_entry
    |> GoalEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a goal_entry.

  ## Examples

      iex> delete_goal_entry(goal_entry)
      {:ok, %GoalEntry{}}

      iex> delete_goal_entry(goal_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_goal_entry(%GoalEntry{} = goal_entry) do
    Repo.delete(goal_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking goal_entry changes.

  ## Examples

      iex> change_goal_entry(goal_entry)
      %Ecto.Changeset{data: %GoalEntry{}}

  """
  def change_goal_entry(%GoalEntry{} = goal_entry, attrs \\ %{}) do
    GoalEntry.changeset(goal_entry, attrs)
  end

  def increment_goal_entry_count(%GoalEntry{} = goal_entry) do
    from(ge in GoalEntry,
      update: [inc: [count: 1]],
      where: ge.id == ^goal_entry.id
    )
    |> Repo.update_all([])
  end
end
