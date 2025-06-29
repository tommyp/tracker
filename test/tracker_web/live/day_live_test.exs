defmodule TrackerWeb.DayLiveTest do
  alias Tracker.Goals
  use TrackerWeb.ConnCase

  import Phoenix.LiveViewTest

  import Tracker.GoalsFixtures

  test "visiting the page shows the nav", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "Yesterday"
    assert html =~ "Today"
    assert html =~ "Tomorrow"
  end

  test "clicking on yesterday redirects to yesterday's date", %{conn: conn} do
    yesterday = Date.utc_today() |> Date.add(-1)

    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("button#yesterday")
    |> render_click()

    assert_patch(view, ~p"/?date=#{Date.to_string(yesterday)}")
  end

  test "clicking on tomorrow redirects to tomorrow's date", %{conn: conn} do
    tomorrow = Date.utc_today() |> Date.add(1)

    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("button#tomorrow")
    |> render_click()

    assert_patch(view, ~p"/?date=#{Date.to_string(tomorrow)}")
  end

  test "renders goals", %{conn: conn} do
    goal_1 = numeric_goal_fixture(%{description: "Eat breakfast"})
    goal_2 = numeric_goal_fixture(%{description: "Go for a walk"})

    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ goal_1.description
    assert html =~ goal_2.description
  end

  test "toggles a goal completed", %{conn: conn} do
    goal_1 = boolean_goal_fixture(%{description: "Eat breakfast"})

    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("button#toggle-completed-#{goal_1.id}")
    |> render_click()

    [entry] = Goals.list_goal_entries()

    assert entry.goal_id == goal_1.id
    assert entry.completed == true

    view
    |> element("button#toggle-completed-#{goal_1.id}")
    |> render_click()

    entry = Tracker.Repo.reload!(entry)
    assert entry.completed == false
  end

  test "increments and decrements a numeric goal", %{conn: conn} do
    goal = numeric_goal_fixture(%{description: "Meditate for 10 minutes"})

    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("button#increment-#{goal.id}")
    |> render_click()

    [entry] = Goals.list_goal_entries()

    assert entry.goal_id == goal.id
    assert entry.count == 1

    view
    |> element("button#increment-#{goal.id}")
    |> render_click()

    entry = Tracker.Repo.reload!(entry)
    assert entry.count == 2

    view
    |> element("button#increment-#{goal.id}")
    |> render_click()

    entry = Tracker.Repo.reload!(entry)
    assert entry.count == 3

    view
    |> element("button#decrement-#{goal.id}")
    |> render_click()

    entry = Tracker.Repo.reload!(entry)
    assert entry.count == 2

    view
    |> element("button#decrement-#{goal.id}")
    |> render_click()

    entry = Tracker.Repo.reload!(entry)
    assert entry.count == 1

    view
    |> element("button#decrement-#{goal.id}")
    |> render_click()

    assert nil == Tracker.Repo.reload(entry)
  end

  test "can set a count against a goal", %{conn: conn} do
    goal = numeric_goal_fixture(%{description: "Meditate for 10 minutes"})

    {:ok, view, _html} = live(conn, ~p"/")

    html =
      view
      |> element("button#open-set-count-modal-#{goal.id}")
      |> render_click()

    assert html =~ "Set count"

    html =
      view
      |> form("#goal-entry-form", goal_entry: %{count: 5})
      |> render_submit()

    assert html =~ "5"
  end
end
