defmodule Tracker.GoalsTest do
  use Tracker.DataCase

  alias Tracker.Goals

  describe "goals" do
    alias Tracker.Goals.Goal

    import Tracker.GoalsFixtures

    @invalid_attrs %{type: nil, description: nil, numeric_target: nil}

    test "list_goals/0 returns all goals" do
      goal = goal_fixture()
      assert Goals.list_goals() == [goal]
    end

    test "get_goal!/1 returns the goal with given id" do
      goal = goal_fixture()
      assert Goals.get_goal!(goal.id) == goal
    end

    test "create_goal/1 with valid data creates a goal" do
      valid_attrs = %{type: :numeric, description: "some description", numeric_target: 42}

      assert {:ok, %Goal{} = goal} = Goals.create_goal(valid_attrs)
      assert goal.type == :numeric
      assert goal.description == "some description"
      assert goal.numeric_target == 42
    end

    test "create_goal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Goals.create_goal(@invalid_attrs)
    end

    test "update_goal/2 with valid data updates the goal" do
      goal = goal_fixture()

      update_attrs = %{
        type: :boolean,
        description: "some updated description",
        numeric_target: 43
      }

      assert {:ok, %Goal{} = goal} = Goals.update_goal(goal, update_attrs)
      assert goal.type == :boolean
      assert goal.description == "some updated description"
      assert goal.numeric_target == 43
    end

    test "update_goal/2 with invalid data returns error changeset" do
      goal = goal_fixture()
      assert {:error, %Ecto.Changeset{}} = Goals.update_goal(goal, @invalid_attrs)
      assert goal == Goals.get_goal!(goal.id)
    end

    test "delete_goal/1 deletes the goal" do
      goal = goal_fixture()
      assert {:ok, %Goal{}} = Goals.delete_goal(goal)
      assert_raise Ecto.NoResultsError, fn -> Goals.get_goal!(goal.id) end
    end

    test "change_goal/1 returns a goal changeset" do
      goal = goal_fixture()
      assert %Ecto.Changeset{} = Goals.change_goal(goal)
    end
  end
end
