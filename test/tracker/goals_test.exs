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

    test "list_goals_with_entries_for_date/0 returns all goals" do
      goal_1 = goal_fixture()
      date = Date.utc_today()

      {:ok, entry} =
        Goals.create_goal_entry(goal_1, %{
          date: date,
          completed: true
        })

      goal_2 = goal_fixture()

      assert Goals.list_goals_with_entries_for_date(date) == [{goal_1, entry}, {goal_2, nil}]
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

  describe "goal_entries" do
    alias Tracker.Goals.GoalEntry

    import Tracker.GoalsFixtures

    @invalid_attrs %{count: nil, date: nil, completed: nil}

    test "list_goal_entries/0 returns all goal_entries" do
      goal_entry = goal_entry_fixture()
      assert Goals.list_goal_entries() == [goal_entry]
    end

    test "get_goal_entry!/1 returns the goal_entry with given id" do
      goal_entry = goal_entry_fixture()
      assert Goals.get_goal_entry!(goal_entry.id) == goal_entry
    end

    test "create_goal_entry/1 with valid data creates a goal_entry" do
      valid_attrs = %{count: 42, date: ~D[2025-06-27], completed: true}

      assert {:ok, %GoalEntry{} = goal_entry} = Goals.create_goal_entry(valid_attrs)
      assert goal_entry.count == 42
      assert goal_entry.date == ~D[2025-06-27]
      assert goal_entry.completed == true
    end

    test "create_goal_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Goals.create_goal_entry(@invalid_attrs)
    end

    test "update_goal_entry/2 with valid data updates the goal_entry" do
      goal_entry = goal_entry_fixture()
      update_attrs = %{count: 43, date: ~D[2025-06-28], completed: false}

      assert {:ok, %GoalEntry{} = goal_entry} = Goals.update_goal_entry(goal_entry, update_attrs)
      assert goal_entry.count == 43
      assert goal_entry.date == ~D[2025-06-28]
      assert goal_entry.completed == false
    end

    test "update_goal_entry/2 with invalid data returns error changeset" do
      goal_entry = goal_entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Goals.update_goal_entry(goal_entry, @invalid_attrs)
      assert goal_entry == Goals.get_goal_entry!(goal_entry.id)
    end

    test "delete_goal_entry/1 deletes the goal_entry" do
      goal_entry = goal_entry_fixture()
      assert {:ok, %GoalEntry{}} = Goals.delete_goal_entry(goal_entry)
      assert_raise Ecto.NoResultsError, fn -> Goals.get_goal_entry!(goal_entry.id) end
    end

    test "change_goal_entry/1 returns a goal_entry changeset" do
      goal_entry = goal_entry_fixture()
      assert %Ecto.Changeset{} = Goals.change_goal_entry(goal_entry)
    end
  end
end
