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

    test "create_goal/1 can create a numeric goal" do
      numeric_attrs = %{type: :numeric, description: "Do 42 pushups", numeric_target: 42}

      assert {:ok, %Goal{} = goal} = Goals.create_goal(numeric_attrs)
      assert goal.type == :numeric
      assert goal.description == "Do 42 pushups"
      assert goal.numeric_target == 42
    end

    test "create_goal/1 cannot create a numeric goal with number less than or equal to 0" do
      invalid_attrs = %{type: :numeric, description: "Do -1 pushups", numeric_target: -1}

      assert {:error, changeset} = Goals.create_goal(invalid_attrs)

      assert changeset.errors ==
               [
                 numeric_target:
                   {"must be greater than %{number}",
                    [{:validation, :number}, {:kind, :greater_than}, {:number, 0}]}
               ]

      invalid_attrs = %{type: :numeric, description: "Do 0 pushups", numeric_target: 0}

      assert {:error, changeset} = Goals.create_goal(invalid_attrs)

      assert changeset.errors ==
               [
                 numeric_target:
                   {"must be greater than %{number}",
                    [{:validation, :number}, {:kind, :greater_than}, {:number, 0}]}
               ]
    end

    test "create_goal/1 can create a boolean goal" do
      boolean_attrs = %{type: :boolean, description: "Go for a walk"}

      assert {:ok, %Goal{} = goal} = Goals.create_goal(boolean_attrs)
      assert goal.type == :boolean
      assert goal.description == "Go for a walk"
      assert goal.numeric_target == nil
    end

    test "create_goal/1 cannot create a boolean goal with a numeric target" do
      invalid_attrs = %{type: :boolean, description: "Go for a 1km walk", numeric_target: 1000}

      assert {:error, changeset} = Goals.create_goal(invalid_attrs)

      assert changeset.errors ==
               [type: {"A boolean goal cannot have a target", []}]
    end

    test "create_goal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Goals.create_goal(@invalid_attrs)
    end

    test "update_goal/2 with valid data updates the goal" do
      goal = goal_fixture()

      update_attrs = %{
        type: :boolean,
        description: "some updated description",
        numeric_target: nil
      }

      assert {:ok, %Goal{} = goal} = Goals.update_goal(goal, update_attrs)
      assert goal.type == :boolean
      assert goal.description == "some updated description"
      assert goal.numeric_target == nil
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
