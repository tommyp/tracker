defmodule Tracker.GoalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tracker.Goals` context.
  """

  @doc """
  Generate a goal.
  """
  def goal_fixture(attrs \\ %{}) do
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
end
