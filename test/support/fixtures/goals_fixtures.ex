defmodule Tracker.GoalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tracker.Goals` context.
  """

  @doc """
  Generate a numeric goal.
  """
  def numeric_goal_fixture(attrs \\ %{}) do
    {:ok, goal} =
      attrs
      |> Enum.into(%{
        description: "some description",
        numeric_target: 42,
        type: :numeric
      })
      |> Tracker.Goals.create_goal()

    goal
  end

  def boolean_goal_fixture(attrs \\ %{}) do
    {:ok, goal} =
      attrs
      |> Enum.into(%{
        description: "some description",
        type: :boolean
      })
      |> Tracker.Goals.create_goal()

    goal
  end

  @doc """
  Generate a goal_entry.
  """
  def goal_entry_fixture(goal, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        completed: true,
        count: 42,
        date: ~D[2025-06-27]
      })

    {:ok, goal_entry} =
      goal
      |> Tracker.Goals.create_goal_entry(attrs)

    goal_entry
  end
end
